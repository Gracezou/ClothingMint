//
//  Clothing_MintApp.swift
//  Clothing Mint
//
//  DailyMint 应用入口，注入全局状态
//

import SwiftUI

@main
struct Clothing_MintApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
    }
}
