//
//  QiniuUploadService.swift
//  Clothing Mint
//
//  七牛云图片上传服务，支持 Token 缓存、进度回调、重试和超时
//

import Foundation
import UIKit

/// 七牛云上传服务
final class QiniuUploadService {

    /// 上传进度回调类型
    typealias ProgressHandler = @Sendable (Double) -> Void

    /// 单次上传超时时间（秒）
    private static let uploadTimeout: TimeInterval = 60

    /// 最大重试次数
    private static let maxRetries = 3

    // MARK: - Token 缓存

    private var cachedToken: String?
    private var tokenExpireTime: Date?

    /// 获取上传 Token（有缓存则复用，过期后重新获取）
    func fetchToken() async throws -> String {
        // 检查缓存是否有效（提前 5 分钟视为过期）
        if let token = cachedToken, let expireTime = tokenExpireTime,
           Date.now < expireTime.addingTimeInterval(-5 * 60) {
            AppLogger.debug("使用缓存 Token")
            return token
        }

        var request = URLRequest(url: AppConstants.qiniuTokenURL)
        request.timeoutInterval = AppConstants.requestTimeout
        request.httpMethod = "GET"

        AppLogger.info("获取七牛 Token: \(AppConstants.qiniuTokenURL)")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.error("获取 Token 失败: 非 HTTP 响应")
            throw QiniuUploadError.tokenFetchFailed
        }

        AppLogger.info("Token 响应状态: \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "无内容"
            AppLogger.error("获取 Token 失败: HTTP \(httpResponse.statusCode), body: \(body)")
            throw QiniuUploadError.tokenFetchFailed
        }

        let body = String(data: data, encoding: .utf8) ?? ""
        AppLogger.debug("Token 响应体: \(body)")

        // 尝试多种响应格式解析
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            // 格式1: {"token": "xxx"}
            if let token = json["token"] as? String {
                cacheToken(token)
                return token
            }
            // 格式2: {"data": {"token": "xxx"}}
            if let dataObj = json["data"] as? [String: Any],
               let token = dataObj["token"] as? String {
                cacheToken(token)
                return token
            }
            // 格式3: {"data": "token_string"}
            if let token = json["data"] as? String {
                cacheToken(token)
                return token
            }
        }

        // 如果响应就是纯文本 token
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !trimmed.hasPrefix("{") {
            cacheToken(trimmed)
            return trimmed
        }

        AppLogger.error("无法解析 Token 响应: \(body)")
        throw QiniuUploadError.tokenFetchFailed
    }

    private func cacheToken(_ token: String) {
        cachedToken = token
        // 七牛 Token 默认有效期 1 小时，缓存 55 分钟
        tokenExpireTime = Date.now.addingTimeInterval(AppConstants.qiniuTokenExpiry)
        AppLogger.info("Token 已缓存，有效期至 \(tokenExpireTime!)")
    }

    /// 清除缓存的 Token（上传失败时可调用以强制刷新）
    func invalidateToken() {
        cachedToken = nil
        tokenExpireTime = nil
    }

    // MARK: - 上传

    /// 上传图片到七牛云（带重试和超时）
    /// - Parameters:
    ///   - image: 要上传的图片
    ///   - progress: 上传进度回调（0.0 ~ 1.0）
    /// - Returns: 上传后的完整图片 URL
    func upload(image: UIImage, progress: ProgressHandler? = nil) async throws -> String {
        AppLogger.info("开始上传图片")

        // 生成 key: prefix/yyyyMMdd/uuid
        let datePart = DateFormatters.compactDate.string(from: .now)
        let fullKey = "\(AppConstants.qiniuKeyPrefix)/\(datePart)/\(UUID().uuidString)"
        AppLogger.debug("生成的 key: \(fullKey)")

        // 压缩图片（宽 ≤ 1920, 高 ≤ 1080，根据大小自动选择质量）
        let resizedImage = image.resizedToFit(maxWidth: 1920, maxHeight: 1080)
        guard let imageData = resizedImage.adaptiveJPEGData() else {
            throw QiniuUploadError.imageCompressionFailed
        }
        AppLogger.info("图片压缩完成: \(imageData.count / 1024)KB")

        var lastError: Error?

        for attempt in 1...Self.maxRetries {
            do {
                AppLogger.debug("第 \(attempt) 次尝试上传")
                progress?(0)

                // 获取 Token（使用缓存，失败时清除重试）
                let token: String
                do {
                    token = try await fetchToken()
                } catch {
                    invalidateToken()
                    throw error
                }

                // 带超时的上传
                let returnedKey = try await withThrowingTaskGroup(of: String.self) { group in
                    group.addTask {
                        try await self.doUpload(
                            imageData: imageData,
                            key: fullKey,
                            token: token,
                            progress: progress
                        )
                    }
                    group.addTask {
                        try await Task.sleep(for: .seconds(Self.uploadTimeout))
                        throw QiniuUploadError.uploadTimeout
                    }

                    guard let result = try await group.next() else {
                        throw QiniuUploadError.uploadFailed(detail: "上传任务异常终止")
                    }
                    group.cancelAll()
                    return result
                }

                // 上传成功，返回相对 key（不含域名前缀）
                AppLogger.info("上传成功，key: \(returnedKey)")
                progress?(1.0)
                return returnedKey

            } catch {
                lastError = error
                AppLogger.error("上传失败（第 \(attempt)/\(Self.maxRetries) 次）: \(error.localizedDescription)")

                // 上传失败可能是 Token 过期，清除缓存
                if attempt == 1 {
                    invalidateToken()
                }

                if attempt < Self.maxRetries {
                    try? await Task.sleep(for: .seconds(2))
                }
            }
        }

        throw lastError ?? QiniuUploadError.uploadFailed(detail: "已重试 \(Self.maxRetries) 次")
    }

    /// 执行单次上传
    private func doUpload(imageData: Data, key: String, token: String, progress: ProgressHandler?) async throws -> String {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        body.appendMultipartField(name: "token", value: token, boundary: boundary)
        body.appendMultipartField(name: "key", value: key, boundary: boundary)
        body.appendMultipartFile(name: "file", filename: "\(key).jpg", mimeType: "image/jpeg", data: imageData, boundary: boundary)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        var request = URLRequest(url: AppConstants.qiniuUploadURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = Self.uploadTimeout

        let delegate = UploadProgressDelegate(progressHandler: progress)
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        defer { session.invalidateAndCancel() }

        let (data, response) = try await session.upload(for: request, from: body)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QiniuUploadError.uploadFailed(detail: "非 HTTP 响应")
        }

        let responseBody = String(data: data, encoding: .utf8) ?? ""
        AppLogger.info("七牛上传响应: HTTP \(httpResponse.statusCode), body: \(responseBody)")

        guard (200...299).contains(httpResponse.statusCode) else {
            throw QiniuUploadError.uploadFailed(detail: "HTTP \(httpResponse.statusCode): \(responseBody)")
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let returnedKey = json["key"] as? String {
            return returnedKey
        }

        return key
    }
}

// MARK: - 上传进度代理

private final class UploadProgressDelegate: NSObject, URLSessionTaskDelegate, Sendable {
    let progressHandler: QiniuUploadService.ProgressHandler?

    init(progressHandler: QiniuUploadService.ProgressHandler?) {
        self.progressHandler = progressHandler
    }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0 else { return }
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        progressHandler?(progress)
    }
}

// MARK: - 错误类型

enum QiniuUploadError: LocalizedError {
    case tokenFetchFailed
    case imageCompressionFailed
    case uploadFailed(detail: String = "")
    case uploadTimeout

    var errorDescription: String? {
        switch self {
        case .tokenFetchFailed: "获取上传凭证失败，请检查网络"
        case .imageCompressionFailed: "图片压缩失败"
        case .uploadFailed(let detail):
            detail.isEmpty ? "图片上传失败" : "图片上传失败: \(detail)"
        case .uploadTimeout: "上传超时"
        }
    }
}

// MARK: - Data 扩展

private extension Data {
    mutating func appendMultipartField(name: String, value: String, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
        append("\(value)\r\n".data(using: .utf8)!)
    }

    mutating func appendMultipartFile(name: String, filename: String, mimeType: String, data: Data, boundary: String) {
        append("--\(boundary)\r\n".data(using: .utf8)!)
        append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        append(data)
        append("\r\n".data(using: .utf8)!)
    }
}
