//
//  ToastView.swift
//  Clothing Mint
//
//  彩色 Toast 通知组件
//

import SwiftUI

/// Toast 类型
enum ToastType {
    case success
    case warning
    case error
    case info

    var color: Color {
        switch self {
        case .success: .toastSuccess
        case .warning: .toastWarning
        case .error: .toastError
        case .info: .toastInfo
        }
    }

    var icon: String {
        switch self {
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .error: "xmark.circle.fill"
        case .info: "info.circle.fill"
        }
    }
}

/// Toast 通知视图
struct ToastView: View {
    let type: ToastType
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .font(.title3)

            Text(message)
                .font(.subheadline)
                .lineLimit(2)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(type.color)
                .shadow(color: type.color.opacity(0.3), radius: 8, y: 4)
        )
        .padding(.horizontal, 24)
    }
}

#Preview {
    VStack(spacing: 16) {
        ToastView(type: .success, message: "保存成功")
        ToastView(type: .warning, message: "上传超时，请重试")
        ToastView(type: .error, message: "网络连接失败")
        ToastView(type: .info, message: "正在加载数据...")
    }
}
