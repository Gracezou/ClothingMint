//
//  StatisticsHomeView.swift
//  Clothing Mint
//
//  统计首页：条码搜索、销售总额、TOP3 品类、位置统计
//

import SwiftUI

/// 统计首页
struct StatisticsHomeView: View {
    @State private var viewModel = StatisticsViewModel()
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 搜索栏
                        searchBar

                        // 搜索结果
                        if !viewModel.searchResults.isEmpty {
                            searchResultsSection
                        } else if !viewModel.searchText.isEmpty && !viewModel.isSearching {
                            emptySearchState
                        } else {
                            // 统计内容
                            salesOverviewCard
                            topCategoriesSection
                            locationStatsSection
                        }
                    }
                    .padding(16)
                }
                .refreshable {
                    await viewModel.refresh()
                }

                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .navigationTitle("统计")
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .clothingDetail(let id):
                    ClothingDetailView(clothingId: id)
                default:
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            try? await AuthService().logout()
                            withAnimation {
                                appState.isAuthenticated = false
                                appState.currentUserId = nil
                            }
                        }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toast(isPresented: $viewModel.showToast, type: viewModel.toastType, message: viewModel.toastMessage)
            .task {
                await viewModel.loadStatistics()
            }
        }
    }

    // MARK: - 搜索栏

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("搜索条码 / 描述", text: $viewModel.searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit {
                        Task { await viewModel.search() }
                    }

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if !viewModel.searchText.isEmpty {
                Button("搜索") {
                    Task { await viewModel.search() }
                }
                .font(.subheadline.bold())
                .foregroundStyle(Color.mintPrimary)
            }
        }
    }

    // MARK: - 搜索结果

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("搜索结果")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(viewModel.searchResults.count) 条")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(viewModel.searchResults) { item in
                NavigationLink(value: AppRoute.clothingDetail(id: item.id)) {
                    searchResultRow(item)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func searchResultRow(_ item: ClothingInventory) -> some View {
        HStack(spacing: 12) {
            // 条码图标
            Image(systemName: "barcode")
                .font(.title3)
                .foregroundStyle(Color.mintPrimary)
                .frame(width: 40, height: 40)
                .background(Color.mintPrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.code)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundStyle(.primary)

                HStack(spacing: 6) {
                    Text(item.type)
                    Text("·")
                    Text(item.size)
                    Text("·")
                    Text(item.color)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("¥\(String(format: "%.0f", item.price))")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.mintPrimary)

                if item.isSold {
                    Text("已售")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var emptySearchState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title)
                .foregroundStyle(.secondary.opacity(0.5))
            Text("未找到匹配结果")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    // MARK: - 销售总览卡片

    private var salesOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("销售概况")
                    .font(.subheadline.bold())
                Spacer()
            }

            HStack(spacing: 0) {
                // 销售总额
                statItem(
                    title: "销售总额",
                    value: "¥\(String(format: "%.0f", viewModel.soldStats.totalRevenue))",
                    icon: "yensign.circle.fill",
                    color: Color.mintPrimary
                )

                Divider().frame(height: 50)

                // 销售总量
                statItem(
                    title: "销售总量",
                    value: "\(viewModel.soldStats.totalQuantity) 件",
                    icon: "bag.fill",
                    color: .orange
                )
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statItem(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - TOP3 品类

    private var topCategoriesSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("TOP3 品类")
                    .font(.subheadline.bold())
                Spacer()
            }

            HStack(spacing: 12) {
                // 销量 TOP3
                rankCard(
                    title: "销量排行",
                    ranks: viewModel.soldStats.topQuantityCategories,
                    unit: "件"
                )

                // 收入 TOP3
                rankCard(
                    title: "收入排行",
                    ranks: viewModel.soldStats.topRevenueCategories,
                    unit: "¥",
                    isRevenue: true
                )
            }
        }
    }

    private func rankCard(title: String, ranks: [CategoryRank], unit: String, isRevenue: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            if ranks.isEmpty {
                Text("暂无数据")
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                ForEach(Array(ranks.enumerated()), id: \.element.id) { index, rank in
                    HStack(spacing: 8) {
                        // 排名标识
                        Text("\(index + 1)")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(rankColor(index)))

                        Text(rank.category)
                            .font(.caption)
                            .lineLimit(1)

                        Spacer()

                        Text(isRevenue ? "\(unit)\(String(format: "%.0f", rank.value))" : "\(Int(rank.value))\(unit)")
                            .font(.caption.bold())
                            .foregroundStyle(Color.mintPrimary)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: .orange
        case 1: .gray
        case 2: .brown
        default: .secondary
        }
    }

    // MARK: - 位置统计

    private var locationStatsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("各位置库存")
                    .font(.subheadline.bold())
                Spacer()
                Text("共 \(viewModel.locationStats.count) 个位置")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if viewModel.locationStats.isEmpty && !viewModel.isLoading {
                Text("暂无数据")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(viewModel.locationStats) { stat in
                    locationStatRow(stat)
                }
            }
        }
    }

    private func locationStatRow(_ stat: LocationStatistic) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title3)
                .foregroundStyle(Color.mintPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(stat.location)
                    .font(.subheadline)

                Text("主要品类: \(stat.primaryCategory)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("\(stat.count) 件")
                .font(.subheadline.bold())
                .foregroundStyle(Color.mintPrimary)
        }
        .padding(14)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    StatisticsHomeView()
        .environment(AppState())
}
