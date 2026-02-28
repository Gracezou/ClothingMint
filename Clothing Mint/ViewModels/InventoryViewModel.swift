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
    var allTypeOptions: [String] = [] // 全部类型（初始加载获取）
    var statistics = OverviewStatistics()

    // MARK: - 筛选

    var selectedLocation: String?
    var selectedType: String?

    /// 当前筛选变更任务（用于取消上一次请求）
    private var filterTask: Task<Void, Never>?

    /// 当前是否有筛选条件
    private var hasFilter: Bool {
        selectedLocation != nil || selectedType != nil
    }

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
    private let dictService = DictService()
    private var notificationObserver: Any?

    init() {
        // 监听 Realtime 数据变更通知
        notificationObserver = NotificationCenter.default.addObserver(
            forName: .clothingDataChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { await self.refresh() }
        }
    }

    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
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
            async let typesTask = dictService.getByCategory("clothing_type")

            locations = try await locationsTask
            let items = try await itemsTask
            clothingItems = items
            statistics = try await statsTask
            allTypeOptions = try await typesTask.map(\.name).sorted()
            hasMorePages = items.count >= AppConstants.defaultPageSize
        } catch {
            showError("加载数据失败: \(error.localizedDescription)")
        }
        isLoading = false
    }

    /// 加载更多（分页预加载）
    func loadMoreIfNeeded(currentItem: ClothingInventory) async {
        // 筛选模式不分页
        guard !hasFilter, hasMorePages, !isLoadingMore else { return }

        // 到达 80% 位置时触发
        let threshold = Int(Double(clothingItems.count) * 0.8)
        guard let index = clothingItems.firstIndex(where: { $0.id == currentItem.id }),
              index >= threshold else { return }

        isLoadingMore = true
        let nextPage = currentPage + 1
        do {
            let newItems = try await clothingService.getList(page: nextPage)
            if !newItems.isEmpty {
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
            clothingItems = try await fetchFilteredItems()
            statistics = try await statisticsService.getOverviewStatistics(
                location: selectedLocation
            )
            locations = try await clothingService.getAvailableLocations()
            if !hasFilter {
                hasMorePages = clothingItems.count >= AppConstants.defaultPageSize
            }
        } catch {
            showError("刷新失败")
        }
        isRefreshing = false
    }

    // MARK: - 筛选操作

    /// 筛选条件变更时调用（由 View 层 .onChange 触发，带防抖取消）
    func onFilterChanged() {
        filterTask?.cancel()
        filterTask = Task { await performFilter() }
    }

    private func performFilter() async {
        isLoading = true
        currentPage = 0
        hasMorePages = false
        do {
            clothingItems = try await fetchFilteredItems()
            statistics = try await statisticsService.getOverviewStatistics(
                location: selectedLocation
            )
            if !hasFilter {
                hasMorePages = clothingItems.count >= AppConstants.defaultPageSize
            }
        } catch {
            showError("筛选失败")
        }
        isLoading = false
    }

    /// 根据当前筛选条件获取数据
    private func fetchFilteredItems() async throws -> [ClothingInventory] {
        switch (selectedLocation, selectedType) {
        case let (location?, type?):
            return try await clothingService.getByLocationAndType(location: location, type: type)
        case let (location?, nil):
            return try await clothingService.getByLocation(location)
        case let (nil, type?):
            return try await clothingService.getByType(type)
        case (nil, nil):
            return try await clothingService.getList(page: 0)
        }
    }

    // MARK: - 私有

    private func showError(_ message: String) {
        AppLogger.error(message)
        toastType = .error
        toastMessage = message
        showToast = true
    }
}
