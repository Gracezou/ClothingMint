//
//  StatisticsRepository.swift
//  Clothing Mint
//
//  统计数据访问层
//

import Foundation
import Supabase

/// 统计数据仓库
struct StatisticsRepository {
    private let client = SupabaseManager.client
    private let table = AppConstants.clothingTable

    /// 获取库存总览统计（可按位置过滤）
    func getOverviewStatistics(location: String? = nil) async throws -> OverviewStatistics {
        var query = client.from(table).select().is("stock_out_date", value: nil)

        if let location {
            query = query.eq("location", value: location)
        }

        let items: [ClothingInventory] = try await query.execute().value

        let totalCount = items.count
        let listedCount = items.filter(\.isListed).count
        var typeDistribution: [String: Int] = [:]
        for item in items {
            typeDistribution[item.type, default: 0] += 1
        }

        return OverviewStatistics(
            totalCount: totalCount,
            listedCount: listedCount,
            typeDistribution: typeDistribution
        )
    }

    /// 获取销售统计
    func getSoldStatistics() async throws -> SoldStatistics {
        let items: [ClothingInventory] = try await client
            .from(table)
            .select()
            .not("stock_out_date", operator: .is, value: "null" as String)
            .execute()
            .value

        let totalRevenue = items.map(\.price).reduce(0, +)
        let totalQuantity = items.count

        // 按品类统计数量
        var categoryCount: [String: Int] = [:]
        var categoryRevenue: [String: Double] = [:]
        for item in items {
            categoryCount[item.type, default: 0] += 1
            categoryRevenue[item.type, default: 0] += item.price
        }

        let topQuantity = categoryCount
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { CategoryRank(category: $0.key, value: Double($0.value)) }

        let topRevenue = categoryRevenue
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { CategoryRank(category: $0.key, value: $0.value) }

        return SoldStatistics(
            totalRevenue: totalRevenue,
            totalQuantity: totalQuantity,
            topQuantityCategories: topQuantity,
            topRevenueCategories: topRevenue
        )
    }

    /// 获取位置统计
    func getLocationStatistics() async throws -> [LocationStatistic] {
        let items: [ClothingInventory] = try await client
            .from(table)
            .select()
            .is("stock_out_date", value: nil)
            .execute()
            .value

        var locationGroups: [String: [ClothingInventory]] = [:]
        for item in items {
            locationGroups[item.location, default: []].append(item)
        }

        return locationGroups.map { location, items in
            let primaryCategory = Dictionary(grouping: items, by: \.type)
                .max(by: { $0.value.count < $1.value.count })?
                .key ?? ""

            return LocationStatistic(
                location: location,
                count: items.count,
                primaryCategory: primaryCategory
            )
        }
        .sorted { $0.count > $1.count }
    }
}
