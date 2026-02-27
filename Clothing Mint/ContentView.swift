//
//  ContentView.swift
//  Clothing Mint
//
//  根视图，根据认证状态切换页面
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            // 主题色渐变背景
            GradientBackground()

            VStack(spacing: 24) {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)

                Text("DailyMint")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("智能服装库存管理")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
