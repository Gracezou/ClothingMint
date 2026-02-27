//
//  BarcodeGenerator.swift
//  Clothing Mint
//
//  条码生成器，使用 CoreImage 生成 Code128 条码图片
//

import SwiftUI
import CoreImage.CIFilterBuiltins

/// 条码生成工具
enum BarcodeGenerator {

    /// 生成 Code128 条码图片
    /// - Parameters:
    ///   - code: 条码内容
    ///   - width: 输出宽度（点）
    ///   - height: 输出高度（点）
    /// - Returns: 条码 UIImage，生成失败返回 nil
    static func generateCode128(code: String, width: CGFloat = 300, height: CGFloat = 80) -> UIImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = Data(code.utf8)
        filter.quietSpace = 10

        guard let outputImage = filter.outputImage else {
            AppLogger.error("条码生成失败: CIFilter 输出为空")
            return nil
        }

        // 缩放到目标尺寸
        let scaleX = width / outputImage.extent.width
        let scaleY = height / outputImage.extent.height
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            AppLogger.error("条码生成失败: CGImage 转换失败")
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    /// 生成条码 SwiftUI Image
    static func generateBarcodeImage(code: String, width: CGFloat = 300, height: CGFloat = 80) -> Image? {
        guard let uiImage = generateCode128(code: code, width: width, height: height) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}
