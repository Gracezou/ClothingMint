//
//  BluetoothPrintService.swift
//  Clothing Mint
//
//  蓝牙打印服务，协调 BLE 连接和打印协议
//

import Foundation

/// 蓝牙打印服务
@Observable final class BluetoothPrintService {
    let bleManager = BLEManager()

    /// 打印协议列表（按优先级排序：HM-T → ESC/POS → TSPL → 纯文本）
    private let protocols: [PrintProtocol] = [
        HMTPrintProtocol(),
        ESCPOSPrintProtocol(),
        TSPLPrintProtocol(),
        PlainTextPrintProtocol()
    ]

    /// 每个协议最大重试次数
    private let maxRetries = 3

    /// 打印标签
    /// - Parameters:
    ///   - code: 条码编号
    ///   - type: 服装类型
    ///   - size: 尺码
    ///   - color: 颜色
    ///   - price: 价格
    /// - Returns: 是否打印成功
    func printLabel(code: String, type: String, size: String, color: String, price: String) async -> Bool {
        for printProtocol in protocols {
            AppLogger.info("尝试协议: \(printProtocol.name)")

            let labelData = printProtocol.buildLabelData(
                code: code, type: type, size: size, color: color, price: price
            )

            for attempt in 1...maxRetries {
                AppLogger.debug("协议 \(printProtocol.name) 第 \(attempt) 次尝试")

                let success = await withCheckedContinuation { continuation in
                    bleManager.sendData(labelData) { success in
                        continuation.resume(returning: success)
                    }
                }

                if success {
                    AppLogger.info("打印成功（协议: \(printProtocol.name)，尝试: \(attempt)）")
                    return true
                }

                // 短暂等待后重试
                try? await Task.sleep(for: .milliseconds(500))
            }

            AppLogger.warning("协议 \(printProtocol.name) 失败，尝试下一个")
        }

        AppLogger.error("所有打印协议均失败")
        return false
    }
}
