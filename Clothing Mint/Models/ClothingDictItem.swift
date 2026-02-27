//
//  ClothingDictItem.swift
//  Clothing Mint
//
//  字典项数据模型，对应 sample_clothing_dict 表
//

import Foundation

/// 字典项（品类/颜色/尺码等下拉选项）
struct ClothingDictItem: Codable, Identifiable, Hashable {
    let id: String
    let category: String
    let name: String
    let sortNo: Int

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case name
        case sortNo = "sort_no"
    }
}
