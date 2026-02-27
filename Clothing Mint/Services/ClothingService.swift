//
//  ClothingService.swift
//  Clothing Mint
//
//  服装库存业务逻辑层
//

import Foundation
import Supabase

/// 服装库存服务
struct ClothingService {
    private let repo = ClothingRepository()

    /// 分页获取库存
    func getList(page: Int, pageSize: Int = AppConstants.defaultPageSize) async throws -> [ClothingInventory] {
        try await NetworkRetry.execute {
            try await repo.getList(page: page, pageSize: pageSize)
        }
    }

    /// 按位置获取库存
    func getByLocation(_ location: String) async throws -> [ClothingInventory] {
        try await NetworkRetry.execute {
            try await repo.getByLocation(location)
        }
    }

    /// 按位置 + 类型获取
    func getByLocationAndType(location: String, type: String) async throws -> [ClothingInventory] {
        try await NetworkRetry.execute {
            try await repo.getByLocationAndType(location: location, type: type)
        }
    }

    /// 获取所有在用位置
    func getAvailableLocations() async throws -> [String] {
        try await NetworkRetry.execute {
            try await repo.getAvailableLocations()
        }
    }

    /// 按 ID 获取
    func getById(_ id: String) async throws -> ClothingInventory {
        try await NetworkRetry.execute {
            try await repo.getById(id)
        }
    }

    /// 搜索
    func search(keyword: String) async throws -> [ClothingInventory] {
        try await NetworkRetry.execute {
            try await repo.search(keyword: keyword)
        }
    }

    /// 创建服装记录
    func create(_ clothing: ClothingInventory) async throws {
        try await NetworkRetry.execute {
            try await repo.create(clothing)
        }
    }

    /// 更新服装记录
    func update(id: String, data: [String: AnyJSON]) async throws {
        try await NetworkRetry.execute {
            try await repo.update(id: id, data: data)
        }
    }
}
