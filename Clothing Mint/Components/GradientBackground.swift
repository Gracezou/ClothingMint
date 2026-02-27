//
//  GradientBackground.swift
//  Clothing Mint
//
//  可复用的薄荷绿渐变背景
//

import SwiftUI

/// 薄荷绿渐变背景
struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [.gradientStart, .gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground()
}
