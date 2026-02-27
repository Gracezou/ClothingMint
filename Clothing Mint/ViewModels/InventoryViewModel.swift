//
//  InventoryViewModel.swift
//  Clothing Mint
//
//  库存总览视图模型
//

import SwiftUI

/// 库存总览视图模型
@Observable
final class InventoryViewModel {
    // MARK: - 数据

    var clothingItems: [ClothingInventory] = []
    var locations: [String] = []
    var typeOptions: [String] = []
    var statistics = OverviewStatistics()

    // MARK: - 筛选

    var selectedLocation: String? {
        didSet { Task { await onLocationChanged() } }
    }
    var selectedType: String?

    // MARK: - 状态

    var isLoading = false
    var isRefreshing = false
    var showToast = false
    var toastType: ToastType = .error
    var toastMessage = ""

    // MARK: - 依赖

    private let clothingService = ClothingService()
    private let statisticsService = StatisticsService()

    // MARK: - 初始加载

    func loadInitialData() async {
        isLoading = true
        do {
            async let locationsTask = clothingService.getAvailableLocations()
            async let itemsTask = clothingService.getList(page: 0)
            async let statsTask = statisticsService.getOverviewStatistics()

            locations = try await locationsTask
            clothingItems = try await itemsTask
            statistics = try await statsTask
        } catch {
            showError("加载数据失败: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// 刷新数据
    func refresh() async {
        isRefreshing = true
        do {
            if let location = selectedLocation {
                if let type = selectedType {
                    clothingItems = try await clothingService.getByLocationAndType(location: location, type: type)
                } else {
                    clothingItems = try await clothingService.getByLocation(location)
                }
                statistics = try await statisticsService.getOverviewStatistics(location: location)
            } else {
                clothingItems = try await clothingService.getList(page: 0)
                statistics = try await statisticsService.getOverviewStatistics()
            }
            locations = try await clothingService.getAvailableLocations()
        } catch {
            showError("刷新失败")
        }
        isRefreshing = false
    }

    // MARK: - 筛选操作

    private func onLocationChanged() async {
        selectedType = nil
        isLoading = true
        do {
            if let location = selectedLocation {
                clothingItems = try await clothingService.getByLocation(location)
                statistics = try await statisticsService.getOverviewStatistics(location: location)
                // 从当前数据提取可用类型
                typeOptions = Array(Set(clothingItems.map(\.type))).sorted()
            } else {
                clothingItems = try await clothingService.getList(page: 0)
                statistics = try await statisticsService.getOverviewStatistics()
                typeOptions = []
            }
        } catch {
            showError("筛选失败")
        }
        isLoading = false
    }

    /// 按类型筛选
    func filterByType(_ type: String?) async {
        selectedType = type
        guard let location = selectedLocation else { return }

        isLoading = true
        do {
            if let type {
                clothingItems = try await clothingService.getByLocationAndType(location: location, type: type)
            } else {
                clothingItems = try await clothingService.getByLocation(location)
            }
        } catch {
            showError("筛选失败")
        }
        isLoading = false
    }

    // MARK: - 私有

    private func showError(_ message: String) {
        AppLogger.error(message)
        toastType = .error
        toastMessage = message
        showToast = true
    }
}
