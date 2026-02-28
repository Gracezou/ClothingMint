//
//  AppConstants.swift
//  Clothing Mint
//
//  Clothing Mint 全局配置常量
//

import Foundation

/// 全局配置常量
enum AppConstants: Sendable {

    // MARK: - Supabase

    /// Supabase 项目 URL
    static let supabaseURL = URL(string: "https://wyqzgryuxyfrsenyupls.supabase.co")!

    /// Supabase 匿名 Key
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5cXpncnl1eHlmcnNlbnl1cGxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc5ODg1NzIsImV4cCI6MjA1MzU2NDU3Mn0.fZSF9D7ihMHdqhOtDiWA14F2VghrMVpcekNOxe3Nvls"

    // MARK: - 七牛云

    /// 七牛上传 Token 服务器地址
    static let qiniuTokenURL = URL(string: "http://124.71.145.245:5177/api/token")!

    /// 七牛 CDN 域名
    static let qiniuCDNDomain = "http://qiniu2.daxiaoxiang.com"

    /// 七牛上传地址（东南亚区域）
    static let qiniuUploadURL = URL(string: "https://up-as0.qiniup.com")!

    /// 七牛上传 Key 前缀
    static let qiniuKeyPrefix = "sampleClothing"

    /// 七牛 Token 有效期（秒）
    static let qiniuTokenExpiry: TimeInterval = 2 * 60 * 60 // 2 小时

    // MARK: - 数据库表名

    /// 服装库存主表
    static let clothingTable = "sample_clothing_inventory"

    /// 字典表
    static let dictTable = "sample_clothing_dict"

    // MARK: - 网络配置

    /// 请求超时时间（秒）
    static let requestTimeout: TimeInterval = 30

    /// 最大重试次数
    static let maxRetryCount = 3

    /// 重试间隔（秒）
    static let retryInterval: TimeInterval = 2

    // MARK: - 分页

    /// 默认每页大小
    static let defaultPageSize = 20
}
