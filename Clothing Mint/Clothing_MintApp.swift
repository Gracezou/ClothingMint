//
//  Clothing_MintApp.swift
//  Clothing Mint
//
//  Clothing Mint 应用入口，注入全局状态，处理 Deep Link
//

import SwiftUI

@main
struct Clothing_MintApp: App {
    @State private var appState = AppState()

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
    /// 支持格式：clothingmint://detail/{id} — 跳转服装详情
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "clothingmint" else { return }

        switch url.host {
        case "detail":
            if let id = url.pathComponents.last, id != "/" {
                appState.deepLinkRoute = .clothingDetail(id: id)
                AppLogger.info("Deep Link: 跳转详情 \(id)")
            }
        default:
            AppLogger.debug("未知 Deep Link: \(url)")
        }
    }
}
