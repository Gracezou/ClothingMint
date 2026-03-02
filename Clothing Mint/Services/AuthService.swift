//
//  AuthService.swift
//  Clothing Mint
//
//  认证服务，封装 Supabase Auth 操作
//

import Foundation
import Supabase
import Auth

/// 认证服务
struct AuthService {
    private let client = SupabaseManager.client

    /// 邮箱密码登录
    func login(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
        AppLogger.info("用户登录成功: \(email)")
    }

    /// 注册新用户
    func signUp(email: String, password: String) async throws {
        try await client.auth.signUp(
            email: email,
            password: password,
            redirectTo: URL(string: "https://gracezou.github.io/ClothingMint/confirm")
        )
        AppLogger.info("用户注册成功: \(email)")
    }

    /// 发送重置密码邮件
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(
            email,
            redirectTo: URL(string: "https://gracezou.github.io/ClothingMint/reset-password")
        )
        AppLogger.info("已发送密码重置邮件: \(email)")
    }

    /// 退出登录
    func logout() async throws {
        try await client.auth.signOut()
        AppLogger.info("用户已退出登录")
    }

    /// 获取当前会话用户 ID
    func getCurrentUserId() async -> String? {
        try? await client.auth.session.user.id.uuidString
    }

    /// 检查是否已登录（含 session 过期检查）
    func isLoggedIn() async -> Bool {
        guard let session = try? await client.auth.session else {
            return false
        }
        // emitLocalSessionAsInitialSession 会返回本地缓存的 session
        // 需要检查是否过期，过期则尝试刷新
        if session.isExpired {
            AppLogger.info("会话已过期，尝试刷新...")
            do {
                _ = try await client.auth.refreshSession()
                return true
            } catch {
                AppLogger.error("刷新会话失败: \(error.localizedDescription)")
                return false
            }
        }
        return true
    }
}
