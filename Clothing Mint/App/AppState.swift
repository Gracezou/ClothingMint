//
//  AppState.swift
//  Clothing Mint
//
//  全局应用状态，管理认证状态和 Tab 选择
//

import SwiftUI

/// 全局应用状态
@Observable
final class AppState {
    /// 当前认证状态
    var isAuthenticated = false

    /// 当前用户 ID
    var currentUserId: String?

    /// 当前选中的 Tab 索引（0: 统计, 1: 库存）
    var selectedTab = 0

    /// 是否正在检查认证状态
    var isCheckingAuth = true

    /// 是否显示新建服装表单
    var showCreateClothing = false

    /// Deep Link 路由（设置后由主视图消费并清空）
    var deepLinkRoute: AppRoute?
}
