//
//  SplashView.swift
//  Clothing Mint
//
//  欢迎页，启动动画 + 自动导航
//

import SwiftUI

/// 欢迎页
struct SplashView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = SplashViewModel()

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 20) {
                Spacer()

                // Logo 图标
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)
                    .scaleEffect(viewModel.showLogo ? 1 : 0.3)
                    .opacity(viewModel.showLogo ? 1 : 0)
                    .rotationEffect(.degrees(viewModel.showLogo ? 0 : -30))

                // 应用名称
                Text("Clothing Mint")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .offset(y: viewModel.showTitle ? 0 : 30)
                    .opacity(viewModel.showTitle ? 1 : 0)

                // 副标题
                Text("智能服装库存管理")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.85))
                    .opacity(viewModel.showSubtitle ? 1 : 0)

                Spacer()

                // 版本号
                Text("v\(viewModel.appVersion)")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
                    .opacity(viewModel.showVersion ? 1 : 0)
                    .padding(.bottom, 40)
            }
        }
        .task {
            // 并行执行动画和认证检查
            async let animation: () = viewModel.startAnimations()
            async let isLoggedIn = viewModel.checkAuth()

            await animation
            let loggedIn = await isLoggedIn

            // 动画完成后根据认证状态更新
            if loggedIn {
                if let userId = await AuthService().getCurrentUserId() {
                    appState.currentUserId = userId
                }
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                appState.isAuthenticated = loggedIn
                appState.isCheckingAuth = false
            }
        }
    }
}

#Preview {
    SplashView()
        .environment(AppState())
}
