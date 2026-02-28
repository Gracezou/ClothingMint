//
//  RealtimeService.swift
//  Clothing Mint
//
//  Supabase Realtime 实时同步服务，监听库存表变化
//

import Foundation
import Supabase

/// 实时同步服务
@Observable final class RealtimeService {
    /// 数据变更回调
    var onDataChanged: (() -> Void)?

    private var channel: RealtimeChannelV2?
    private static let maxReconnectAttempts = 5
    private static let reconnectDelay: TimeInterval = 3

    /// 开始监听库存表变化（含自动重连）
    func startListening() async {
        var attempt = 0

        while !Task.isCancelled && attempt < Self.maxReconnectAttempts {
            do {
                try await listenOnce()
                // listenOnce 正常返回说明 for-await 结束（频道关闭或取消）
                if Task.isCancelled { break }
            } catch {
                attempt += 1
                AppLogger.error("Realtime: 监听异常（第 \(attempt) 次）: \(error.localizedDescription)")
            }

            // 重连前清理
            await stopListening()

            guard !Task.isCancelled else { break }
            AppLogger.info("Realtime: \(Self.reconnectDelay)s 后尝试重连...")
            try? await Task.sleep(for: .seconds(Self.reconnectDelay))
        }

        if attempt >= Self.maxReconnectAttempts {
            AppLogger.error("Realtime: 已达最大重连次数 \(Self.maxReconnectAttempts)，停止重连")
        }
    }

    /// 单次监听（内部方法）
    private func listenOnce() async throws {
        let channel = SupabaseManager.client.realtimeV2.channel("inventory-changes")

        let changes = channel.postgresChange(
            AnyAction.self,
            table: AppConstants.clothingTable
        )

        await channel.subscribe()
        self.channel = channel

        AppLogger.info("Realtime: 开始监听库存表变化")

        for await _ in changes {
            guard !Task.isCancelled else {
                AppLogger.info("Realtime: 监听任务已取消")
                return
            }
            AppLogger.debug("Realtime: 收到数据变更")
            onDataChanged?()
        }
    }

    /// 停止监听
    func stopListening() async {
        if let channel {
            await channel.unsubscribe()
            self.channel = nil
            AppLogger.info("Realtime: 停止监听")
        }
    }
}
