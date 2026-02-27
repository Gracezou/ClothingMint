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

    /// 开始监听库存表变化
    func startListening() async {
        let channel = SupabaseManager.client.realtimeV2.channel("inventory-changes")

        let changes = channel.postgresChange(
            AnyAction.self,
            table: AppConstants.clothingTable
        )

        await channel.subscribe()
        self.channel = channel

        AppLogger.info("Realtime: 开始监听库存表变化")

        for await _ in changes {
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
