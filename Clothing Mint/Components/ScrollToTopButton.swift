//
//  ScrollToTopButton.swift
//  Clothing Mint
//
//  浮动回到顶部按钮
//

import SwiftUI

/// 回到顶部浮动按钮
struct ScrollToTopButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.body.bold())
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(Color.mintPrimary.opacity(0.9))
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                )
        }
    }
}
