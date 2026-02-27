//
//  ClothingInventory.swift
//  Clothing Mint
//
//  服装库存数据模型，对应 sample_clothing_inventory 表
//

import Foundation

/// 服装库存记录
struct ClothingInventory: Codable, Identifiable, Hashable {
    let id: String
    var code: String
    var merchantId: String
    var size: String
    var color: String
    var type: String
    var location: String
    var photoUrl: String?
    var price: Double
    var description: String?
    var stockInDate: Date
    var stockOutDate: Date?
    var soldPrice: Double?
    var xianyuLink: String?
    var xianyuPrice: Double?
    var isReturned: Bool
    var returnTime: Date?
    var createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case merchantId = "merchant_id"
        case size
        case color
        case type
        case location
        case photoUrl = "photo_url"
        case price
        case description
        case stockInDate = "stock_in_date"
        case stockOutDate = "stock_out_date"
        case soldPrice = "sold_price"
        case xianyuLink = "xianyu_link"
        case xianyuPrice = "xianyu_price"
        case isReturned = "is_returned"
        case returnTime = "return_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// 是否已售出
    var isSold: Bool {
        stockOutDate != nil
    }

    /// 是否已上架（有闲鱼链接即视为已上架）
    var isListed: Bool {
        xianyuLink != nil && !xianyuLink!.isEmpty
    }
}
