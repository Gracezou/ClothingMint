//
//  StatisticsModels.swift
//  Clothing Mint
//
//  统计相关数据模型
//

import Foundation

/// 库存总览统计
struct OverviewStatistics {
    /// 总数量
    var totalCount: Int = 0
    /// 已上架数量
    var listedCount: Int = 0
    /// 按类型分布 [类型名: 数量]
    var typeDistribution: [String: Int] = [:]
}

/// 销售统计
struct SoldStatistics {
    /// 销售总额
    var totalRevenue: Double = 0
    /// 销售总量
    var totalQuantity: Int = 0
    /// 销量 TOP3 品类
    var topQuantityCategories: [CategoryRank] = []
    /// 收入 TOP3 品类
    var topRevenueCategories: [CategoryRank] = []
}

/// 品类排名项
struct CategoryRank: Identifiable {
    let id = UUID()
    let category: String
    let value: Double // 数量或金额
}

/// 位置统计项
struct LocationStatistic: Identifiable {
    let id = UUID()
    let location: String
    let count: Int
    let primaryCategory: String
}
