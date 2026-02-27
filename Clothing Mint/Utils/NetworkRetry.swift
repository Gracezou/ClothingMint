//
//  NetworkRetry.swift
//  Clothing Mint
//
//  通用异步重试机制，最多重试 3 次，间隔 2 秒
//

import Foundation

/// 带重试的异步操作执行器
enum NetworkRetry {
    /// 执行异步操作，失败时自动重试
    /// - Parameters:
    ///   - maxAttempts: 最大尝试次数（默认 3）
    ///   - delay: 重试间隔秒数（默认 2）
    ///   - operation: 要执行的异步操作
    /// - Returns: 操作结果
    static func execute<T: Sendable>(
        maxAttempts: Int = 3,
        delay: TimeInterval = 2,
        operation: @Sendable () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 1...maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                AppLogger.warning("操作失败（第 \(attempt)/\(maxAttempts) 次）: \(error.localizedDescription)")

                if attempt < maxAttempts {
                    try await Task.sleep(for: .seconds(delay))
                }
            }
        }

        throw lastError ?? NSError(domain: "NetworkRetry", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "操作在 \(maxAttempts) 次尝试后仍然失败"
        ])
    }
}
