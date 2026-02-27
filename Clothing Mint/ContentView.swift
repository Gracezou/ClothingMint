//
//  ContentView.swift
//  Clothing Mint
//
//  根视图，根据认证状态切换：Splash → Login / Main
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if appState.isCheckingAuth {
                SplashView()
            } else if appState.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.isCheckingAuth)
        .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
