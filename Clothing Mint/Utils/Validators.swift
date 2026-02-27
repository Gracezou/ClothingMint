//
//  Validators.swift
//  Clothing Mint
//
//  表单验证工具
//

import Foundation

/// 表单验证器
enum Validators {
    /// 验证邮箱格式
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    /// 验证非空字符串
    static func isNotEmpty(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// 验证价格（大于 0）
    static func isValidPrice(_ price: Double) -> Bool {
        price > 0
    }
}
