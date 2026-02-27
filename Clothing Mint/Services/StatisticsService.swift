//
//  StatisticsService.swift
//  Clothing Mint
//
//  统计业务逻辑层
//

import Foundation

/// 统计服务
struct StatisticsService {
    private let repo = StatisticsRepository()

    /// 获取库存总览统计
    func getOverviewStatistics(location: String? = nil) async throws -> OverviewStatistics {
        try await NetworkRetry.execute {
            try await repo.getOverviewStatistics(location: location)
        }
    }

    /// 获取销售统计
    func getSoldStatistics() async throws -> SoldStatistics {
        try await NetworkRetry.execute {
            try await repo.getSoldStatistics()
        }
    }

    /// 获取位置统计
    func getLocationStatistics() async throws -> [LocationStatistic] {
        try await NetworkRetry.execute {
            try await repo.getLocationStatistics()
        }
    }
}
