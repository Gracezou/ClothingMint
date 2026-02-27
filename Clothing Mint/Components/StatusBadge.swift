//
//  StatusBadge.swift
//  Clothing Mint
//
//  上架/未上架状态徽章
//

import SwiftUI

/// 状态徽章
struct StatusBadge: View {
    let isListed: Bool

    var body: some View {
        Text(isListed ? "已上架" : "未上架")
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(isListed ? Color.mintPrimary : Color.gray.opacity(0.5))
            )
    }
}

#Preview {
    HStack {
        StatusBadge(isListed: true)
        StatusBadge(isListed: false)
    }
}
