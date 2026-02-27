//
//  SplashViewModel.swift
//  Clothing Mint
//
//  欢迎页视图模型，控制动画时序和认证检查
//

import SwiftUI

/// 欢迎页视图模型
@Observable
final class SplashViewModel {
    /// 是否显示 Logo
    var showLogo = false
    /// 是否显示标题
    var showTitle = false
    /// 是否显示副标题
    var showSubtitle = false
    /// 是否显示版本号
    var showVersion = false
    /// 动画是否完成
    var animationCompleted = false

    private let authService = AuthService()

    /// 当前版本号
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    /// 启动动画序列
    func startAnimations() async {
        // 淡入 Logo
        withAnimation(.easeOut(duration: 0.6)) {
            showLogo = true
        }
        try? await Task.sleep(for: .milliseconds(400))

        // 滑入标题
        withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
            showTitle = true
        }
        try? await Task.sleep(for: .milliseconds(300))

        // 淡入副标题
        withAnimation(.easeOut(duration: 0.4)) {
            showSubtitle = true
        }
        try? await Task.sleep(for: .milliseconds(200))

        // 淡入版本号
        withAnimation(.easeOut(duration: 0.3)) {
            showVersion = true
        }

        // 等待动画展示
        try? await Task.sleep(for: .milliseconds(800))

        animationCompleted = true
    }

    /// 检查认证状态
    func checkAuth() async -> Bool {
        await authService.isLoggedIn()
    }
}
