//
//  StatisticsViewModel.swift
//  Clothing Mint
//
//  统计首页 ViewModel，管理搜索、统计数据加载
//

import Foundation

/// 统计首页 ViewModel
@Observable final class StatisticsViewModel {

    // MARK: - 搜索

    var searchText = ""
    var searchResults: [ClothingInventory] = []
    var isSearching = false

    // MARK: - 统计数据

    var soldStats = SoldStatistics()
    var locationStats: [LocationStatistic] = []
    var isLoading = false

    // MARK: - Toast

    var showToast = false
    var toastType: ToastType = .error
    var toastMessage = ""

    // MARK: - 依赖

    private let statisticsService = StatisticsService()
    private let clothingService = ClothingService()

    // MARK: - 加载统计数据

    func loadStatistics() async {
        isLoading = true
        do {
            async let sold = statisticsService.getSoldStatistics()
            async let locations = statisticsService.getLocationStatistics()
            soldStats = try await sold
            locationStats = try await locations
        } catch {
            showError("加载统计失败: \(error.localizedDescription)")
        }
        isLoading = false
    }

    // MARK: - 刷新

    func refresh() async {
        await loadStatistics()
    }

    // MARK: - 搜索

    func search() async {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        do {
            searchResults = try await clothingService.search(keyword: keyword)
        } catch {
            showError("搜索失败: \(error.localizedDescription)")
        }
        isSearching = false
    }

    func clearSearch() {
        searchText = ""
        searchResults = []
    }

    // MARK: - Toast

    private func showError(_ message: String) {
        toastType = .error
        toastMessage = message
        showToast = true
    }
}
