//
//  View+Extensions.swift
//  Clothing Mint
//
//  View 扩展，提供 Toast 和加载遮罩修饰器
//

import SwiftUI

// MARK: - Toast 修饰器

extension View {
    /// 显示 Toast 消息
    func toast(isPresented: Binding<Bool>, type: ToastType, message: String) -> some View {
        self.overlay(alignment: .top) {
            if isPresented.wrappedValue {
                ToastView(type: type, message: message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation { isPresented.wrappedValue = false }
                        }
                    }
                    .padding(.top, 50)
            }
        }
        .animation(.spring(duration: 0.3), value: isPresented.wrappedValue)
    }

    /// 显示加载遮罩
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                LoadingOverlay()
            }
        }
    }
}
