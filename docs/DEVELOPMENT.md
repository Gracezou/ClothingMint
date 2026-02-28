# Clothing Mint 开发文档

## 架构概述

Clothing Mint 采用 **MVVM-S**（Model-View-ViewModel-Service）分层架构：

```
┌─────────┐    ┌──────────────┐    ┌───────────┐    ┌──────────────┐
│  View   │ → │  ViewModel   │ → │  Service  │ → │  Repository  │
│ SwiftUI │    │ @Observable  │    │ 业务逻辑   │    │  Supabase    │
└─────────┘    └──────────────┘    └───────────┘    └──────────────┘
```

- **View**：纯 SwiftUI 声明式 UI，不包含业务逻辑
- **ViewModel**：`@Observable` 管理页面状态、表单验证、异步操作
- **Service**：业务逻辑层，包含 `NetworkRetry` 自动重试
- **Repository**：封装 Supabase 查询，返回强类型 `Codable` 模型

---

## 目录结构

```
Clothing Mint/
├── Clothing_MintApp.swift          # App 入口，Deep Link 处理，Kingfisher 配置
├── ContentView.swift               # 根视图（Auth 路由判断）
│
├── App/
│   ├── AppState.swift              # 全局状态（登录态、Deep Link 路由）
│   ├── AppConstants.swift          # 全局配置常量（URL、超时、分页）
│   └── AppRouter.swift             # 路由枚举 AppRoute
│
├── Models/
│   ├── ClothingInventory.swift     # 服装库存主模型（Codable）
│   ├── ClothingDictItem.swift      # 字典项模型（类型、颜色等）
│   ├── StatisticsModels.swift      # 统计相关模型
│   └── QiniuUploadToken.swift      # 七牛 Token 响应模型
│
├── Repositories/
│   ├── SupabaseClient.swift        # Supabase 客户端单例
│   ├── ClothingRepository.swift    # 服装 CRUD 查询
│   ├── DictRepository.swift        # 字典数据查询
│   └── StatisticsRepository.swift  # 统计数据查询
│
├── Services/
│   ├── AuthService.swift           # 认证服务（登录/注册/登出）
│   ├── ClothingService.swift       # 服装业务逻辑 + 重试
│   ├── DictService.swift           # 字典数据服务
│   ├── StatisticsService.swift     # 统计数据服务
│   ├── QiniuUploadService.swift    # 七牛上传（Token 缓存/压缩/重试/超时）
│   ├── RealtimeService.swift       # Supabase Realtime 监听 + 自动重连
│   └── BluetoothPrintService.swift # 蓝牙打印业务层
│
├── ViewModels/
│   ├── AuthViewModel.swift         # 登录/注册表单
│   ├── SplashViewModel.swift       # 欢迎页动画
│   ├── InventoryViewModel.swift    # 库存总览（筛选/分页/刷新）
│   ├── ClothingFormViewModel.swift # 入库表单
│   ├── ClothingDetailViewModel.swift # 服装详情
│   ├── StatisticsViewModel.swift   # 统计首页
│   └── PrinterViewModel.swift      # 蓝牙打印
│
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift         # 登录页
│   │   └── SignupView.swift        # 注册页
│   ├── Splash/
│   │   └── SplashView.swift        # 欢迎页
│   ├── Main/
│   │   ├── MainTabView.swift       # Tab 容器 + Realtime 启动
│   │   └── ArcTabBar.swift         # 弧形底部导航栏
│   ├── Inventory/
│   │   ├── InventoryOverviewView.swift # 库存总览页
│   │   ├── WaterfallGridView.swift     # 瀑布流布局 + 服装卡片
│   │   └── InventoryStatsCard.swift    # 统计卡片
│   ├── Clothing/
│   │   ├── ClothingCreateView.swift    # 入库表单页
│   │   ├── ClothingDetailView.swift    # 服装详情页
│   │   └── BarcodePreviewView.swift    # 条码预览
│   ├── Statistics/
│   │   └── StatisticsHomeView.swift    # 统计首页
│   └── Printer/
│       └── PrinterScanView.swift       # 蓝牙打印页
│
├── Components/
│   ├── CachedAsyncImage.swift      # Kingfisher 图片组件（多级缩略图）
│   ├── FullImageViewer.swift       # 全屏图片预览
│   ├── DropdownPicker.swift        # 下拉筛选器
│   ├── ToastView.swift             # Toast 提示
│   ├── LoadingOverlay.swift        # 加载遮罩
│   ├── StatusBadge.swift           # 上架/未上架状态标签
│   ├── ScrollToTopButton.swift     # 回到顶部按钮
│   ├── GradientBackground.swift    # 渐变背景
│   └── ImagePickerView.swift       # 相册/相机选择器
│
├── Bluetooth/
│   ├── BLEManager.swift            # BLE 设备管理（扫描/连接/传输）
│   └── PrintProtocol.swift         # 打印协议（HM-T/ESC-POS/TSPL/PlainText）
│
├── Utils/
│   ├── Logger.swift                # AppLogger 日志工具
│   ├── NetworkRetry.swift          # 网络请求自动重试
│   ├── BarcodeGenerator.swift      # Code128 条码生成
│   ├── DateFormatters.swift        # 日期格式化器
│   ├── Validators.swift            # 输入验证
│   └── HapticFeedback.swift        # 触觉反馈
│
├── Extensions/
│   ├── Color+Theme.swift           # 主题色定义
│   ├── UIImage+Compression.swift   # 图片压缩扩展
│   ├── Date+Formatting.swift       # 日期格式化扩展
│   ├── String+Extensions.swift     # 字符串扩展
│   └── View+Extensions.swift       # View 修饰符扩展
│
├── Widget/
│   └── InventoryWidget.swift       # 桌面小组件
│
└── Assets.xcassets/                # App Icon + 颜色 + 图片资源
```

---

## 编码规范

### @Observable 使用

- 所有 ViewModel 使用 `@Observable final class`，**不** 使用 `ObservableObject` + `@Published`
- View 中通过 `@State private var viewModel = XxxViewModel()` 持有
- 环境注入使用 `@Environment(AppState.self)` 而非 `@EnvironmentObject`

### Swift 并发

- 所有异步操作使用 `async/await`，避免 completion handler
- 长时间运行的 Task 需检查 `Task.isCancelled`
- `@MainActor` 用于 UI 状态更新
- `Sendable` 用于跨并发域传递的类型

### 命名约定

- ViewModel：`XxxViewModel`
- Service：`XxxService`
- Repository：`XxxRepository`
- View：描述性命名 `XxxView`（如 `ClothingCreateView`）
- 常量：`AppConstants.xxxYyy`

---

## 关键模块说明

### 七牛上传流程

```
1. fetchToken()
   └─ 检查缓存（有效期 2h，提前 5min 过期）
   └─ 缓存失效 → GET /api/token → 解析多种响应格式 → 缓存

2. upload(image:)
   └─ 生成 key: sampleClothing/yyyyMMdd/uuid
   └─ 压缩: resizedToFit(1920×1080) → adaptiveJPEGData()
   └─ 重试循环（最多 3 次）:
       └─ withThrowingTaskGroup 实现超时（60s）
       └─ doUpload: multipart/form-data POST 到 up-as0.qiniup.com
       └─ 失败时 invalidateToken() 强制刷新
```

### 蓝牙打印协议链

```
BluetoothPrintService
  ├─ HMTPrintProtocol    — HM-T 系列热敏打印机
  ├─ ESCPOSPrintProtocol — ESC/POS 通用协议
  ├─ TSPLPrintProtocol   — TSPL 标签打印协议
  └─ PlainTextProtocol   — 纯文本回退

BLEManager
  ├─ 扫描: scanForPeripherals（10s 超时）
  ├─ 连接: connect（10s 超时，didWriteValueFor 回调确认）
  └─ 传输: 20 字节分块 + withCheckedContinuation 等待完成
```

### Supabase Realtime 监听

```
MainTabView.task
  └─ RealtimeService.startListening()
      └─ while 重连循环（最多 5 次，间隔 3s）
          └─ listenOnce()
              ├─ channel.subscribe()
              └─ for await changes → NotificationCenter.post(.clothingDataChanged)

InventoryViewModel.init
  └─ addObserver(.clothingDataChanged) → refresh()
  └─ deinit 中 removeObserver
```

### 图片多级缓存策略

```
七牛 CDN URL 格式:
  列表缩略图: {cdn}/{key}?imageView2/2/w/300
  详情中图:   {cdn}/{key}?imageView2/2/w/600
  全屏原图:   {cdn}/{key}

Kingfisher 缓存配置:
  磁盘: 200MB / 7 天过期
  内存: 100MB
```

---

## 新增功能开发指南

### 添加新的数据模型

1. 在 `Models/` 下创建 `Codable` 结构体
2. 在 `Repositories/` 下创建 Repository，封装 Supabase 查询
3. 在 `Services/` 下创建 Service，添加业务逻辑和重试
4. 在 `ViewModels/` 下创建 `@Observable` ViewModel
5. 在 `Views/` 对应目录下创建 SwiftUI View

### 添加新的打印协议

1. 在 `Bluetooth/PrintProtocol.swift` 中实现 `PrintProtocol`
2. 在 `BluetoothPrintService` 的协议检测链中注册

---

## 环境变量和配置

所有配置集中在 `App/AppConstants.swift`：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| `supabaseURL` | `https://wyqzgryuxyfrsenyupls.supabase.co` | Supabase 项目地址 |
| `supabaseAnonKey` | `eyJ...` | Supabase 匿名 Key |
| `qiniuTokenURL` | `http://124.71.145.245:5177/api/token` | Token 服务地址 |
| `qiniuCDNDomain` | `http://qiniu2.daxiaoxiang.com` | 七牛 CDN 域名 |
| `qiniuUploadURL` | `https://up-as0.qiniup.com` | 七牛上传端点 |
| `qiniuKeyPrefix` | `sampleClothing` | 上传 key 前缀 |
| `defaultPageSize` | `20` | 列表分页大小 |
| `requestTimeout` | `30s` | 网络请求超时 |
| `maxRetryCount` | `3` | 最大重试次数 |
