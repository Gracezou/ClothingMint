//
//  Date+Formatting.swift
//  Clothing Mint
//
//  日期便捷格式化扩展
//

import Foundation

extension Date {
    /// 格式化为显示日期：yyyy-MM-dd
    var displayDate: String {
        DateFormatters.displayDate.string(from: self)
    }

    /// 格式化为显示日期时间：yyyy-MM-dd HH:mm
    var displayDateTime: String {
        DateFormatters.displayDateTime.string(from: self)
    }

    /// 格式化为条码前缀：yyMMdd
    var barcodePrefix: String {
        DateFormatters.barcodePrefix.string(from: self)
    }
}
