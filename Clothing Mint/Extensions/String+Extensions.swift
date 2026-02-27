//
//  String+Extensions.swift
//  Clothing Mint
//
//  字符串扩展，包含条码生成辅助方法
//

import Foundation

extension String {
    /// 生成条码编号：YYMMDD + 6 位随机字母数字
    static func generateBarcode() -> String {
        let prefix = Date().barcodePrefix
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let suffix = (0..<6).map { _ in
            characters.randomElement()!
        }
        return prefix + String(suffix)
    }
}
