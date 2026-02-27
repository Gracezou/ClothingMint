//
//  ClothingRepository.swift
//  Clothing Mint
//
//  服装库存数据访问层，封装 Supabase 查询
//

import Foundation
import Supabase

/// 服装库存数据仓库
struct ClothingRepository {
    private let client = SupabaseManager.client
    private let table = AppConstants.clothingTable

    /// 分页获取库存列表（排除已售）
    func getList(page: Int, pageSize: Int = 20) async throws -> [ClothingInventory] {
        let offset = page * pageSize
        return try await client
            .from(table)
            .select()
            .is("stock_out_date", value: nil)
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + pageSize - 1)
            .execute()
            .value
    }

    /// 按 ID 获取单条记录
    func getById(_ id: String) async throws -> ClothingInventory {
        try await client
            .from(table)
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    /// 创建服装记录
    func create(_ clothing: ClothingInventory) async throws {
        try await client
            .from(table)
            .insert(clothing)
            .execute()
    }

    /// 更新服装记录
    func update(id: String, data: [String: AnyJSON]) async throws {
        try await client
            .from(table)
            .update(data)
            .eq("id", value: id)
            .execute()
    }

    /// 按位置筛选（排除已售）
    func getByLocation(_ location: String) async throws -> [ClothingInventory] {
        try await client
            .from(table)
            .select()
            .eq("location", value: location)
            .is("stock_out_date", value: nil)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    /// 按位置 + 类型筛选（排除已售）
    func getByLocationAndType(location: String, type: String) async throws -> [ClothingInventory] {
        try await client
            .from(table)
            .select()
            .eq("location", value: location)
            .eq("type", value: type)
            .is("stock_out_date", value: nil)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    /// 获取所有在用的存放位置
    func getAvailableLocations() async throws -> [String] {
        let items: [ClothingInventory] = try await client
            .from(table)
            .select()
            .is("stock_out_date", value: nil)
            .execute()
            .value

        return Array(Set(items.map(\.location))).sorted()
    }

    /// 获取所有未售服装
    func getAllAvailable() async throws -> [ClothingInventory] {
        try await client
            .from(table)
            .select()
            .is("stock_out_date", value: nil)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    /// 搜索服装（条码或描述模糊匹配）
    func search(keyword: String) async throws -> [ClothingInventory] {
        try await client
            .from(table)
            .select()
            .or("code.ilike.%\(keyword)%,description.ilike.%\(keyword)%")
            .order("created_at", ascending: false)
            .execute()
            .value
    }
}
