//
//  LoadingOverlay.swift
//  Clothing Mint
//
//  半透明加载遮罩组件
//

import SwiftUI

/// 加载遮罩视图
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)

                Text("加载中...")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

#Preview {
    LoadingOverlay()
}
