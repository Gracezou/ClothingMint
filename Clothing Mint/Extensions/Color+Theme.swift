//
//  Color+Theme.swift
//  Clothing Mint
//
//  薄荷绿主题色系定义
//

import SwiftUI

extension Color {
    // MARK: - 主色调

    /// 薄荷绿主色
    static let mintPrimary = Color(red: 0.15, green: 0.78, blue: 0.65)

    /// 薄荷绿浅色（背景用）
    static let mintLight = Color(red: 0.73, green: 0.94, blue: 0.87)

    /// 薄荷绿深色（强调用）
    static let mintDark = Color(red: 0.08, green: 0.55, blue: 0.45)

    // MARK: - 渐变色

    /// 主渐变起始色
    static let gradientStart = Color(red: 0.15, green: 0.78, blue: 0.65)

    /// 主渐变结束色
    static let gradientEnd = Color(red: 0.10, green: 0.60, blue: 0.75)

    /// 主渐变
    static var mintGradient: LinearGradient {
        LinearGradient(
            colors: [.gradientStart, .gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - 语义色（Toast 用）

    /// 成功色（绿色）
    static let toastSuccess = Color(red: 0.20, green: 0.78, blue: 0.35)

    /// 警告色（橙色）
    static let toastWarning = Color(red: 1.0, green: 0.60, blue: 0.0)

    /// 错误色（红色）
    static let toastError = Color(red: 0.90, green: 0.25, blue: 0.25)

    /// 信息色（蓝色）
    static let toastInfo = Color(red: 0.20, green: 0.50, blue: 0.90)

    // MARK: - 背景色

    /// 页面背景色
    static let pageBackground = Color(UIColor.systemGroupedBackground)

    /// 卡片背景色
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
}
