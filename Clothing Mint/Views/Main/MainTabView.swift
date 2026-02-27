//
//  MainTabView.swift
//  Clothing Mint
//
//  主页面容器，管理 Tab 切换和 FAB 操作
//

import SwiftUI

/// 主 Tab 视图
struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0
    @State private var showCreateClothing = false

    var body: some View {
        @Bindable var state = appState

        ZStack(alignment: .bottom) {
            // Tab 内容区域（ZStack 保持状态不销毁）
            ZStack {
                // Tab 0: 统计首页
                StatisticsHomeView()
                    .opacity(selectedTab == 0 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 0)

                // Tab 1: 库存总览
                InventoryOverviewView()
                    .opacity(selectedTab == 1 ? 1 : 0)
                    .allowsHitTesting(selectedTab == 1)
            }
            .padding(.bottom, 50) // 给 Tab Bar 留空间

            // 底部弧形导航栏
            ArcTabBar(selectedTab: $selectedTab) {
                showCreateClothing = true
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showCreateClothing) {
            ClothingCreateView()
                .environment(appState)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
