//
//  ClothingInventory.swift
//  Clothing Mint
//
//  服装库存数据模型，对应 sample_clothing_inventory 表
//

import Foundation

/// 服装库存记录
struct ClothingInventory: Codable, Identifiable, Hashable, Sendable {
    let id: String
    var code: String
    var merchantId: String?
    var size: String
    var color: String
    var type: String
    var location: String
    var photoUrl: String?
    var price: Double
    var description: String?
    var stockInDate: String // ISO 8601 字符串，避免日期解码问题
    var stockOutDate: String?
    var xianyuLink: String?
    var isReturned: Bool
    var returnTime: String?
    var createdAt: String
    var updatedAt: String
    var userId: String?

    enum CodingKeys: String, CodingKey {
        case id, code, size, color, type, location, price, description
        case merchantId = "merchant_id"
        case photoUrl = "photo_url"
        case stockInDate = "stock_in_date"
        case stockOutDate = "stock_out_date"
        case xianyuLink = "xianyu_link"
        case isReturned = "is_returned"
        case returnTime = "return_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userId = "user_id"
    }

    /// 是否已售出
    var isSold: Bool {
        stockOutDate != nil
    }

    /// 是否已上架（有闲鱼链接即视为已上架）
    var isListed: Bool {
        guard let link = xianyuLink else { return false }
        return !link.isEmpty
    }

    /// 图片完整 URL（拼接 CDN 域名）
    var fullPhotoUrl: String? {
        guard let url = photoUrl, !url.isEmpty else { return nil }
        let baseUrl = url.hasPrefix("http") ? url : "\(AppConstants.qiniuCDNDomain)/\(url)"
        return baseUrl
    }

    /// 列表缩略图 URL（七牛 WebP 压缩）
    var thumbnailUrl: String? {
        guard let base = fullPhotoUrl else { return nil }
        return "\(base)?imageMogr2/format/webp/quality/85"
    }

    /// 格式化的入库日期
    var displayStockInDate: String {
        formatDateString(stockInDate)
    }

    /// 格式化的出库日期
    var displayStockOutDate: String? {
        stockOutDate.map { formatDateString($0) }
    }

    /// 格式化的创建日期
    var displayCreatedAt: String {
        formatDateString(createdAt)
    }

    private func formatDateString(_ isoString: String) -> String {
        // 截取 yyyy-MM-dd 部分
        if isoString.count >= 10 {
            return String(isoString.prefix(10))
        }
        return isoString
    }
}
