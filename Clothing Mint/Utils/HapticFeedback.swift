//
//  HapticFeedback.swift
//  Clothing Mint
//
//  触觉反馈便捷方法
//

import UIKit

/// 触觉反馈管理器
enum HapticFeedback {
    /// 轻触反馈
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// 中等触感反馈
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// 成功反馈
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// 错误反馈
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
