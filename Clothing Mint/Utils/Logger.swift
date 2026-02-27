//
//  Logger.swift
//  Clothing Mint
//
//  分级日志工具，支持 Error/Warning/Info/Debug 四个级别
//

import Foundation
import os

/// 应用日志管理器
enum AppLogger {
    private static let logger = os.Logger(subsystem: "com.daxiaoxiang.Clothing-Mint", category: "App")

    /// 错误日志
    static func error(_ message: String, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        logger.error("❌ [\(fileName):\(line)] \(message)")
    }

    /// 警告日志
    static func warning(_ message: String, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        logger.warning("⚠️ [\(fileName):\(line)] \(message)")
    }

    /// 信息日志
    static func info(_ message: String) {
        logger.info("ℹ️ \(message)")
    }

    /// 调试日志
    static func debug(_ message: String) {
        #if DEBUG
        logger.debug("🔍 \(message)")
        #endif
    }
}
