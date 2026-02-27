//
//  PrintProtocol.swift
//  Clothing Mint
//
//  打印协议定义 + 4 种协议实现（HM-T / ESC-POS / TSPL / 纯文本）
//

import Foundation

/// 打印协议接口
protocol PrintProtocol {
    var name: String { get }
    func buildLabelData(code: String, type: String, size: String, color: String, price: String) -> Data
}

// MARK: - HM-T 协议（汉印热敏打印机）

struct HMTPrintProtocol: PrintProtocol {
    let name = "HM-T"

    func buildLabelData(code: String, type: String, size: String, color: String, price: String) -> Data {
        var data = Data()
        // 初始化
        data.append(contentsOf: [0x1B, 0x40]) // ESC @
        // 打印模式：标签
        data.append(contentsOf: [0x1B, 0x69, 0x61, 0x00]) // 标准模式
        // 标签尺寸（40mm x 30mm）
        data.append(contentsOf: [0x1B, 0x69, 0x7A])
        data.append(contentsOf: [0x02, 0x04, 0x00, 0x00, 0xA0, 0x00, 0x78, 0x00, 0x00, 0x00])

        // 条码
        let barcodeCmd = "^BY2,2,50^FO20,10^BC^FD\(code)^FS"
        data.append(barcodeCmd.data(using: .utf8) ?? Data())

        // 文字信息
        let textCmd = """
        ^FO20,70^A0N,20,20^FD\(type) / \(size) / \(color)^FS
        ^FO20,95^A0N,20,20^FD$\(price)^FS
        ^XZ
        """
        data.append(textCmd.data(using: .utf8) ?? Data())

        return data
    }
}

// MARK: - ESC/POS 协议（通用小票打印机）

struct ESCPOSPrintProtocol: PrintProtocol {
    let name = "ESC/POS"

    func buildLabelData(code: String, type: String, size: String, color: String, price: String) -> Data {
        var data = Data()
        // 初始化打印机
        data.append(contentsOf: [0x1B, 0x40]) // ESC @

        // 居中对齐
        data.append(contentsOf: [0x1B, 0x61, 0x01])

        // 条码设置
        data.append(contentsOf: [0x1D, 0x68, 0x50]) // 条码高度 80
        data.append(contentsOf: [0x1D, 0x77, 0x02]) // 条码宽度 2
        data.append(contentsOf: [0x1D, 0x48, 0x02]) // HRI 字符在下方

        // 打印 Code128 条码
        data.append(contentsOf: [0x1D, 0x6B, 0x49]) // Code128
        let codeBytes = Array(code.utf8)
        data.append(UInt8(codeBytes.count + 2))
        data.append(contentsOf: [0x7B, 0x42]) // Code B
        data.append(contentsOf: codeBytes)

        // 换行
        data.append(contentsOf: [0x0A, 0x0A])

        // 左对齐
        data.append(contentsOf: [0x1B, 0x61, 0x00])

        // 打印文字信息
        let infoText = "\(type) | \(size) | \(color)\n¥\(price)\n"
        if let textData = infoText.data(using: .utf8) {
            data.append(textData)
        }

        // 走纸 + 切纸
        data.append(contentsOf: [0x0A, 0x0A, 0x0A])
        data.append(contentsOf: [0x1D, 0x56, 0x42, 0x00]) // 切纸

        return data
    }
}

// MARK: - TSPL 协议（标签打印机）

struct TSPLPrintProtocol: PrintProtocol {
    let name = "TSPL"

    func buildLabelData(code: String, type: String, size: String, color: String, price: String) -> Data {
        // TSPL 指令集
        let commands = """
        SIZE 40 mm,30 mm
        GAP 2 mm,0
        CLS
        BARCODE 30,20,"128",60,1,0,2,2,"\(code)"
        TEXT 30,90,"2",0,1,1,"\(type) / \(size) / \(color)"
        TEXT 30,115,"2",0,1,1,"¥\(price)"
        PRINT 1

        """
        return commands.data(using: .utf8) ?? Data()
    }
}

// MARK: - 纯文本协议（兜底方案）

struct PlainTextPrintProtocol: PrintProtocol {
    let name = "纯文本"

    func buildLabelData(code: String, type: String, size: String, color: String, price: String) -> Data {
        let text = """
        ========================
        条码: \(code)
        类型: \(type)
        尺码: \(size)
        颜色: \(color)
        价格: ¥\(price)
        ========================


        """
        return text.data(using: .utf8) ?? Data()
    }
}
