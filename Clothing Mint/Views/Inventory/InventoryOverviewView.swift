//
//  InventoryOverviewView.swift
//  Clothing Mint
//
//  库存总览页面：筛选 + 统计卡片 + 瀑布流
//

import SwiftUI

/// 库存总览页面
struct InventoryOverviewView: View {
    @State private var viewModel = InventoryViewModel()
    @State private var scrollOffset: CGFloat = 0
    @State private var showScrollToTop = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    /// 瀑布流列数：iPad 3 列，iPhone 2 列
    private var columnCount: Int {
        sizeClass == .regular ? 3 : 2
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // 锚点
                            Color.clear.frame(height: 0).id("top")

                            // 筛选栏
                            filterBar

                            // 统计卡片
                            InventoryStatsCard(
                                statistics: viewModel.statistics,
                                collapsed: scrollOffset > 100
                            )
                            .padding(.horizontal, 16)

                            // 类型标签（选中位置后显示）
                            if !viewModel.typeOptions.isEmpty {
                                typeTagsBar
                            }

                            // 瀑布流网格
                            if viewModel.clothingItems.isEmpty && !viewModel.isLoading {
                                emptyState
                            } else {
                                WaterfallLayout(columns: columnCount, spacing: 12) {
                                    ForEach(viewModel.clothingItems) { item in
                                        NavigationLink(value: AppRoute.clothingDetail(id: item.id)) {
                                            ClothingCard(item: item)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }

                            Spacer(minLength: 80)
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: ScrollOffsetKey.self,
                                    value: -geo.frame(in: .named("scroll")).origin.y
                                )
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetKey.self) { value in
                        scrollOffset = value
                        showScrollToTop = value > 300
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if showScrollToTop {
                            ScrollToTopButton {
                                withAnimation {
                                    proxy.scrollTo("top", anchor: .top)
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 20)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }

                // 加载遮罩
                if viewModel.isLoading && viewModel.clothingItems.isEmpty {
                    LoadingOverlay()
                }
            }
            .background(Color.pageBackground)
            .navigationTitle("库存")
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .clothingDetail(let id):
                    ClothingDetailView(clothingId: id)
                default:
                    EmptyView()
                }
            }
            .toast(isPresented: $viewModel.showToast, type: viewModel.toastType, message: viewModel.toastMessage)
            .task {
                if viewModel.clothingItems.isEmpty {
                    await viewModel.loadInitialData()
                }
            }
        }
    }

    // MARK: - 子视图

    private var filterBar: some View {
        HStack(spacing: 12) {
            DropdownPicker(
                title: "选择位置",
                options: viewModel.locations,
                selection: $viewModel.selectedLocation
            )

            Spacer()

            Text("\(viewModel.clothingItems.count) 件")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private var typeTagsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 全部标签
                typeTag(label: "全部", isSelected: viewModel.selectedType == nil) {
                    Task { await viewModel.filterByType(nil) }
                }

                ForEach(viewModel.typeOptions, id: \.self) { type in
                    typeTag(label: type, isSelected: viewModel.selectedType == type) {
                        Task { await viewModel.filterByType(type) }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func typeTag(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.mintPrimary : Color.gray.opacity(0.1))
                )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tshirt")
                .font(.system(size: 48))
                .foregroundStyle(.gray.opacity(0.3))

            Text("暂无库存数据")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - ScrollOffset PreferenceKey

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    InventoryOverviewView()
        .environment(AppState())
}
