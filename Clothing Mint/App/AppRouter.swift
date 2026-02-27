//
//  AppRouter.swift
//  Clothing Mint
//
//  应用路由枚举，定义所有导航目标
//

import Foundation

/// 应用内导航路由
enum AppRoute: Hashable {
    /// 服装详情
    case clothingDetail(id: String)
    /// 打印机扫描
    case printerScan
    /// 打印标签预览
    case printPreview(clothingId: String)
}
