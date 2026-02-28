//
//  UIImage+Compression.swift
//  Clothing Mint
//
//  图片压缩扩展：缩放 + HEIC 编码
//

import UIKit

extension UIImage {
    /// 缩放图片使宽不超过 maxWidth、高不超过 maxHeight
    func resizedToFit(maxWidth: CGFloat = 1920, maxHeight: CGFloat = 1080) -> UIImage {
        guard size.width > maxWidth || size.height > maxHeight else { return self }

        let widthScale = maxWidth / size.width
        let heightScale = maxHeight / size.height
        let scale = min(widthScale, heightScale)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// 缩放图片到最长边不超过指定尺寸
    func resizedToMaxDimension(_ maxDimension: CGFloat) -> UIImage {
        resizedToFit(maxWidth: maxDimension, maxHeight: maxDimension)
    }

    /// 自适应压缩 JPEG，确保结果不超过 targetMaxKB
    func adaptiveJPEGData(targetMaxKB: Int = 500) -> Data? {
        // 从 0.8 开始，逐步降低质量直到满足目标大小
        var quality: CGFloat = 0.8
        let minQuality: CGFloat = 0.3

        while quality >= minQuality {
            guard let data = jpegData(compressionQuality: quality) else { return nil }
            let sizeKB = data.count / 1024
            if sizeKB <= targetMaxKB {
                return data
            }
            quality -= 0.1
        }

        // 最低质量仍超限，返回最低质量结果
        return jpegData(compressionQuality: minQuality)
    }

    /// 编码为 HEIC 格式（比 JPEG 体积小 40-50%）
    func heicData(compressionQuality: CGFloat = 0.8) -> Data? {
        guard let cgImage else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, "public.heic" as CFString, 1, nil) else {
            return nil
        }
        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: compressionQuality
        ]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
