//
//  ContentView.swift
//  Clothing Mint
//
//  根视图，根据认证状态切换：Splash → Login / Main
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isCheckingAuth {
                // 启动时显示欢迎页
                SplashView()
            } else if appState.isAuthenticated {
                // 已登录 → 主页（暂用占位视图）
                MainPlaceholderView()
            } else {
                // 未登录 → 登录页
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isCheckingAuth)
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
    }
}

/// 主页占位视图（第 3 批替换为 MainTabView）
struct MainPlaceholderView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.mintPrimary)

                Text("登录成功!")
                    .font(.title2.bold())

                Text("主页面将在第 3 批实现")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    Task {
                        try? await AuthService().logout()
                        withAnimation {
                            appState.isAuthenticated = false
                            appState.currentUserId = nil
                        }
                    }
                } label: {
                    Text("退出登录")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 200, height: 48)
                        .background(Capsule().fill(Color.mintPrimary))
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
