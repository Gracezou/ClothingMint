//
//  QiniuUploadService.swift
//  Clothing Mint
//
//  七牛云图片上传服务，支持进度回调
//

import Foundation
import UIKit

/// 七牛云上传服务
struct QiniuUploadService {

    /// 上传进度回调类型
    typealias ProgressHandler = @Sendable (Double) -> Void

    /// 获取上传 Token
    func fetchToken() async throws -> String {
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
                AppLogger.info("获取 Token 成功（直接格式）")
                return token
            }
            // 格式2: {"data": {"token": "xxx"}}
            if let dataObj = json["data"] as? [String: Any],
               let token = dataObj["token"] as? String {
                AppLogger.info("获取 Token 成功（data 嵌套格式）")
                return token
            }
            // 格式3: {"data": "token_string"}
            if let token = json["data"] as? String {
                AppLogger.info("获取 Token 成功（data 字符串格式）")
                return token
            }
        }

        // 如果响应就是纯文本 token
        let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !trimmed.hasPrefix("{") {
            AppLogger.info("获取 Token 成功（纯文本格式）")
            return trimmed
        }

        AppLogger.error("无法解析 Token 响应: \(body)")
        throw QiniuUploadError.tokenFetchFailed
    }

    /// 上传图片到七牛云
    /// - Parameters:
    ///   - image: 要上传的图片
    ///   - key: 存储 key（不含前缀，会自动拼接）
    ///   - progress: 上传进度回调（0.0 ~ 1.0）
    /// - Returns: 上传后的文件 key
    func upload(image: UIImage, key: String, progress: ProgressHandler? = nil) async throws -> String {
        // 获取 Token
        let token = try await fetchToken()

        // 压缩图片为 JPEG
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw QiniuUploadError.imageCompressionFailed
        }

        let fullKey = "\(AppConstants.qiniuKeyPrefix)/\(key)"
        AppLogger.info("开始上传图片: key=\(fullKey), 大小=\(imageData.count / 1024)KB")

        // 构建 multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()

        // token 字段
        body.appendMultipartField(name: "token", value: token, boundary: boundary)
        // key 字段
        body.appendMultipartField(name: "key", value: fullKey, boundary: boundary)
        // file 字段
        body.appendMultipartFile(name: "file", filename: "\(key).jpg", mimeType: "image/jpeg", data: imageData, boundary: boundary)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        var request = URLRequest(url: AppConstants.qiniuUploadURL)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        // 使用 URLSession upload 支持进度
        let delegate = UploadProgressDelegate(progressHandler: progress)
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        defer { session.invalidateAndCancel() }

        let (data, response) = try await session.upload(for: request, from: body)

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.error("七牛上传失败: 非 HTTP 响应")
            throw QiniuUploadError.uploadFailed(detail: "非 HTTP 响应")
        }

        let responseBody = String(data: data, encoding: .utf8) ?? ""
        AppLogger.info("七牛上传响应: HTTP \(httpResponse.statusCode), body: \(responseBody)")

        guard (200...299).contains(httpResponse.statusCode) else {
            AppLogger.error("七牛上传失败: HTTP \(httpResponse.statusCode)")
            throw QiniuUploadError.uploadFailed(detail: "HTTP \(httpResponse.statusCode): \(responseBody)")
        }

        // 解析返回的 key
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let returnedKey = json["key"] as? String {
            AppLogger.info("七牛上传成功: \(returnedKey)")
            return returnedKey
        }

        AppLogger.info("七牛上传成功: \(fullKey)")
        return fullKey
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

    var errorDescription: String? {
        switch self {
        case .tokenFetchFailed: "获取上传凭证失败，请检查网络"
        case .imageCompressionFailed: "图片压缩失败"
        case .uploadFailed(let detail):
            detail.isEmpty ? "图片上传失败" : "图片上传失败: \(detail)"
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
