//
//  DateFormatters.swift
//  Clothing Mint
//
//  共享日期格式化器，避免重复创建
//

import Foundation

/// 日期格式化工具
enum DateFormatters {
    /// 显示用日期格式：yyyy-MM-dd
    static let displayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    /// 显示用日期时间格式：yyyy-MM-dd HH:mm
    static let displayDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    /// 条码日期前缀格式：yyMMdd
    static let barcodePrefix: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMdd"
        return formatter
    }()

    /// ISO 8601 格式（Supabase 通信用）
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
