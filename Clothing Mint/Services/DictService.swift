//
//  DictService.swift
//  Clothing Mint
//
//  字典服务，获取并缓存下拉选项
//

import Foundation

/// 字典服务
struct DictService {
    private let repo = DictRepository()

    /// 按分类获取字典项
    func getByCategory(_ category: String) async throws -> [ClothingDictItem] {
        try await NetworkRetry.execute {
            try await repo.getByCategory(category)
        }
    }

    /// 批量获取多个分类
    func getBatchCategories(_ categories: [String]) async throws -> [String: [ClothingDictItem]] {
        let items = try await NetworkRetry.execute {
            try await repo.getBatchCategories(categories)
        }
        return Dictionary(grouping: items, by: \.category)
    }
}
