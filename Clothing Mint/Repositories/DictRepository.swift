//
//  DictRepository.swift
//  Clothing Mint
//
//  字典数据访问层
//

import Foundation
import Supabase

/// 字典数据仓库
struct DictRepository {
    private let client = SupabaseManager.client
    private let table = AppConstants.dictTable

    /// 按分类获取字典项
    func getByCategory(_ category: String) async throws -> [ClothingDictItem] {
        try await client
            .from(table)
            .select()
            .eq("category", value: category)
            .order("sort_no", ascending: true)
            .execute()
            .value
    }

    /// 批量获取多个分类（通过存储过程）
    func getBatchCategories(_ categories: [String]) async throws -> [ClothingDictItem] {
        try await client
            .rpc("get_clothing_dict_by_categories", params: ["categories": categories])
            .execute()
            .value
    }
}
