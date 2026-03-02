//
//  Clothing_MintApp.swift
//  Clothing Mint
//
//  Clothing Mint 应用入口，注入全局状态，处理 Deep Link
//

import SwiftUI
import Kingfisher

@main
struct Clothing_MintApp: App {
    @State private var appState = AppState()

    init() {
        configureKingfisher()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    /// 处理 Deep Link
    /// 支持格式：
    /// - clothingmint://detail/{id} — 跳转服装详情
    /// - clothingmint://auth/confirmed — 邮箱验证成功
    /// - clothingmint://auth/password-reset — 密码重置成功
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "clothingmint" else { return }

        switch url.host {
        case "detail":
            if let id = url.pathComponents.last, id != "/" {
                appState.deepLinkRoute = .clothingDetail(id: id)
                AppLogger.info("Deep Link: 跳转详情 \(id)")
            }
        case "auth":
            let action = url.pathComponents.last
            if action == "confirmed" {
                AppLogger.info("Deep Link: 邮箱验证成功")
            } else if action == "password-reset" {
                AppLogger.info("Deep Link: 密码重置成功")
            }
        default:
            AppLogger.debug("未知 Deep Link: \(url)")
        }
    }

    /// 配置 Kingfisher 图片缓存策略
    private func configureKingfisher() {
        let cache = ImageCache.default
        // 磁盘缓存限制 200MB
        cache.diskStorage.config.sizeLimit = 200 * 1024 * 1024
        // 磁盘缓存过期时间 7 天
        cache.diskStorage.config.expiration = .days(7)
        // 内存缓存限制 100MB
        cache.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
    }
}
