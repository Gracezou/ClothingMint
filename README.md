# Clothing Mint

> 智能服装库存管理系统 — Swift 原生 iOS App

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2026+-blue.svg)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-26.2+-purple.svg)](https://developer.apple.com/xcode/)

---

## 截图

> 📱 截图待补充（使用真机录制后替换）

| 库存总览 | 服装详情 | 入库表单 | 蓝牙打印 |
|---------|---------|---------|---------|
| *截图* | *截图* | *截图* | *截图* |

---

## 简介

Clothing Mint 是一款面向个人卖家/小型商户的服装库存管理工具，提供服装入库、出库、闲鱼上架、蓝牙条码打印、销售统计等全流程管理能力。

## 功能特性

- **用户认证** — 邮箱密码登录/注册，会话自动持久化
- **库存总览** — 瀑布流展示、位置/类型独立筛选、统计卡片、分页预加载、下拉刷新
- **服装入库** — 拍照/选图上传七牛云、图片自适应压缩、条码自动生成（Code128）、动态表单
- **服装详情** — 完整信息展示、全屏图片预览、闲鱼链接管理、标记售出/退货
- **图片管理** — 七牛 CDN 多级缩略图（300px 列表 / 600px 详情 / 原图预览）、Kingfisher 缓存
- **统计分析** — 销售总额/总量、TOP3 品类排行、位置库存分布、条码搜索
- **蓝牙打印** — BLE 设备扫描连接、多协议自动切换（HM-T/ESC-POS/TSPL/PlainText）
- **实时同步** — Supabase Realtime 监听，多设备数据即时刷新
- **iPad 适配** — 响应式布局、瀑布流自适应列数、限宽居中

## 技术栈

| 类别 | 技术 |
|------|------|
| 语言 | Swift 6 |
| UI 框架 | SwiftUI (iOS 18+) |
| 状态管理 | @Observable (Observation 框架) |
| 导航 | NavigationStack + 路由枚举 |
| 布局 | 自定义 SwiftUI Layout 协议（瀑布流） |
| 后端 | Supabase (Auth + PostgREST + Realtime) |
| 图片 | Kingfisher (缓存) + 七牛云 CDN (存储) |
| 蓝牙 | CoreBluetooth (BLE) |
| 条码 | CoreImage CICode128BarcodeGenerator |
| CI/CD | GitHub Actions |

## 项目结构

```
Clothing Mint/
├── App/                    # AppState、常量、路由
├── Models/                 # 数据模型（Codable）
├── Repositories/           # Supabase 数据访问层
├── Services/               # 业务逻辑层
├── ViewModels/             # @Observable 视图模型
├── Views/
│   ├── Auth/               # 登录/注册
│   ├── Splash/             # 欢迎页
│   ├── Main/               # 弧形 Tab Bar + 主容器
│   ├── Inventory/          # 库存总览 + 瀑布流
│   ├── Clothing/           # 入库/详情/条码预览
│   ├── Statistics/         # 统计首页
│   └── Printer/            # 蓝牙打印
├── Components/             # 通用组件
├── Bluetooth/              # BLE 管理 + 打印协议
├── Utils/                  # 工具类
├── Extensions/             # 扩展
├── Widget/                 # 桌面小组件
└── Assets.xcassets/        # 资源
```

> 详细架构说明见 [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)

## 快速开始

### 前置要求

- macOS 15+ & Xcode 26.2+
- iOS 18+ 设备或模拟器
- 七牛 Token 服务（地址 `124.71.145.245:5177`）需可达

### 运行步骤

1. 克隆仓库

```bash
git clone git@github.com:Gracezou/ClothingMint.git
cd ClothingMint
```

2. 用 Xcode 打开项目

```bash
open "Clothing Mint.xcodeproj"
```

3. Xcode 会自动解析 SPM 依赖（supabase-swift、Kingfisher）
4. 选择目标设备，点击运行

### SPM 依赖

| 包 | 版本 | 用途 |
|---|------|------|
| [supabase-swift](https://github.com/supabase/supabase-swift) | ~> 2.0 | 认证 + 数据库 + Realtime |
| [Kingfisher](https://github.com/onevcat/Kingfisher) | ~> 8.0 | 图片缓存加载 |

### 环境配置

| 服务 | 说明 |
|------|------|
| Supabase | 项目 URL 和 anon key 配置在 `AppConstants.swift` |
| 七牛云 | Bucket `sampleClothing`，CDN 域名 `qiniu2.daxiaoxiang.com` |
| Token 服务 | `http://124.71.145.245:5177/api/token`（七牛上传凭证） |

## 架构

```
View → ViewModel (@Observable) → Service (重试) → Repository (Supabase)
```

- **View** — 纯 SwiftUI 声明式 UI
- **ViewModel** — 管理页面状态、表单验证、异步操作
- **Service** — 业务逻辑 + NetworkRetry 自动重试
- **Repository** — 封装 Supabase 查询，返回强类型模型

## 主题

采用薄荷绿色系（Mint Green），定义于 `Color+Theme.swift`：

- 主色：`Color.mintPrimary` (HSB: 0.44, 0.81, 0.78)
- 浅色：`Color.mintLight`
- 深色：`Color.mintDark`
- 渐变：`Color.mintGradient`

## CI/CD

GitHub Actions 工作流 `.github/workflows/build.yml`：

- 触发条件：推送 `v*` 标签或手动触发
- 构建：Archive → IPA
- 产出：IPA artifact

```bash
git tag v1.0.0
git push origin v1.0.0
```

## License

MIT
