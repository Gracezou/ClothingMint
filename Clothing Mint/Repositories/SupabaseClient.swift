//
//  SupabaseClient.swift
//  Clothing Mint
//
//  Supabase 客户端单例，统一管理数据库和认证连接
//

import Foundation
import Supabase

/// Supabase 客户端管理器
enum SupabaseManager {
    /// 共享的 Supabase 客户端实例
    static let client = SupabaseClient(
        supabaseURL: AppConstants.supabaseURL,
        supabaseKey: AppConstants.supabaseAnonKey,
        options: SupabaseClientOptions(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}
