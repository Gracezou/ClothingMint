//
//  InventoryViewModel.swift
//  Clothing Mint
//
//  库存总览视图模型，支持分页预加载
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

    // MARK: - 分页

    private var currentPage = 0
    private var hasMorePages = true
    var isLoadingMore = false

    // MARK: - 状态

    var isLoading = false
    var isRefreshing = false
    var showToast = false
    var toastType: ToastType = .error
    var toastMessage = ""

    // MARK: - 依赖

    private let clothingService = ClothingService()
    private let statisticsService = StatisticsService()

    init() {
        // 监听 Realtime 数据变更通知
        NotificationCenter.default.addObserver(
            forName: .clothingDataChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { await self.refresh() }
        }
    }

    // MARK: - 初始加载

    func loadInitialData() async {
        isLoading = true
        currentPage = 0
        hasMorePages = true
        do {
            async let locationsTask = clothingService.getAvailableLocations()
            async let itemsTask = clothingService.getList(page: 0)
            async let statsTask = statisticsService.getOverviewStatistics()

            locations = try await locationsTask
            let items = try await itemsTask
            clothingItems = items
            statistics = try await statsTask
            hasMorePages = items.count >= AppConstants.defaultPageSize
        } catch {
            showError("加载数据失败: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// 加载更多（分页预加载）
    func loadMoreIfNeeded(currentItem: ClothingInventory) async {
        // 仅在无筛选时支持分页
        guard selectedLocation == nil, hasMorePages, !isLoadingMore else { return }

        // 到达 80% 位置时触发
        let threshold = Int(Double(clothingItems.count) * 0.8)
        guard let index = clothingItems.firstIndex(where: { $0.id == currentItem.id }),
              index >= threshold else { return }

        isLoadingMore = true
        let nextPage = currentPage + 1
        do {
            let newItems = try await clothingService.getList(page: nextPage)
            if !newItems.isEmpty {
                // 去重后追加
                let existingIds = Set(clothingItems.map(\.id))
                let uniqueItems = newItems.filter { !existingIds.contains($0.id) }
                clothingItems.append(contentsOf: uniqueItems)
                currentPage = nextPage
                hasMorePages = newItems.count >= AppConstants.defaultPageSize
            } else {
                hasMorePages = false
            }
        } catch {
            AppLogger.error("加载更多失败: \(error.localizedDescription)")
        }
        isLoadingMore = false
    }

    /// 刷新数据
    func refresh() async {
        isRefreshing = true
        currentPage = 0
        hasMorePages = true
        do {
            if let location = selectedLocation {
                if let type = selectedType {
                    clothingItems = try await clothingService.getByLocationAndType(location: location, type: type)
                } else {
                    clothingItems = try await clothingService.getByLocation(location)
                }
                statistics = try await statisticsService.getOverviewStatistics(location: location)
            } else {
                let items = try await clothingService.getList(page: 0)
                clothingItems = items
                statistics = try await statisticsService.getOverviewStatistics()
                hasMorePages = items.count >= AppConstants.defaultPageSize
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
        currentPage = 0
        hasMorePages = false // 筛选模式不分页
        do {
            if let location = selectedLocation {
                clothingItems = try await clothingService.getByLocation(location)
                statistics = try await statisticsService.getOverviewStatistics(location: location)
                typeOptions = Array(Set(clothingItems.map(\.type))).sorted()
            } else {
                let items = try await clothingService.getList(page: 0)
                clothingItems = items
                statistics = try await statisticsService.getOverviewStatistics()
                typeOptions = []
                hasMorePages = items.count >= AppConstants.defaultPageSize
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
