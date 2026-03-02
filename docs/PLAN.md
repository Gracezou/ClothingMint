# DailyMint iOS App 实施计划

## Context

基于 README.md 中的完整功能规格文档，将 DailyMint（智能服装库存管理系统）开发为 Swift 原生 iOS App。当前项目仅有 Xcode 默认模板代码（`Clothing_MintApp.swift` + `ContentView.swift`），需从零构建全部功能。

项目已配置：Xcode 26.2、Swift 6 严格并发（`@MainActor` 默认隔离）、iPhone + iPad 双设备支持（`TARGETED_DEVICE_FAMILY = "1,2"`）、文件系统同步（新文件自动加入构建，无需手动编辑 pbxproj）。

---

## 项目目录结构

所有源文件位于 `Clothing Mint/Clothing Mint/` 下：

```
Clothing Mint/
├── Clothing_MintApp.swift              // 入口（改造）
├── ContentView.swift                   // 根路由（改造）
├── Info.plist                          // 权限声明
├── App/
│   ├── AppState.swift                  // 全局状态（@Observable）
│   ├── AppConstants.swift              // Supabase/七牛/CDN 常量
│   └── AppRouter.swift                 // 路由枚举
├── Models/
│   ├── ClothingInventory.swift
│   ├── ClothingDictItem.swift
│   ├── QiniuUploadToken.swift
│   └── StatisticsModels.swift
├── Repositories/
│   ├── SupabaseClient.swift            // Supabase 单例
│   ├── ClothingRepository.swift
│   ├── DictRepository.swift
│   └── StatisticsRepository.swift
├── Services/
│   ├── AuthService.swift
│   ├── ClothingService.swift
│   ├── StatisticsService.swift
│   ├── DictService.swift
│   ├── QiniuUploadService.swift
│   └── BluetoothPrintService.swift
├── ViewModels/                         // 各页面 ViewModel
├── Views/
│   ├── Splash/SplashView.swift
│   ├── Auth/LoginView.swift, SignupView.swift
│   ├── Main/MainTabView.swift, ArcTabBar.swift
│   ├── Statistics/StatisticsHomeView.swift
│   ├── Inventory/InventoryOverviewView.swift, StatsCard, WaterfallGrid
│   ├── Clothing/ClothingCreateView.swift, DetailView, BarcodePreview
│   └── Printer/PrinterScanView.swift, PrintLabelPreviewView.swift
├── Components/                         // 通用组件（Toast, LoadingOverlay, CachedAsyncImage 等）
├── Utils/                              // 工具类（Logger, NetworkRetry, BarcodeGenerator 等）
├── Extensions/                         // 扩展（Color+Theme, View+Extensions 等）
├── Bluetooth/                          // BLE 管理 + 4 种打印协议
└── Assets.xcassets/
```

## SPM 依赖（仅 2 个）

| 包 | 用途 |
|---|------|
| [supabase-swift](https://github.com/supabase/supabase-swift) ~> 2.0 | 认证 + 数据库 |
| [Kingfisher](https://github.com/onevcat/Kingfisher) ~> 8.0 | 图片缓存加载 |

七牛上传使用 `URLSession` 直传（multipart/form-data），不引入额外 SDK。

## 关键技术决策

- **纯 SwiftUI** + 仅相机拍照用 `UIViewControllerRepresentable`
- **@Observable** 替代 ObservableObject（iOS 17+ Observation 框架）
- **NavigationStack** + 路由枚举实现导航
- **自定义 SwiftUI Shape** 绘制弧形 Tab Bar（非 UIBezierPath）
- **SwiftUI Layout 协议**实现瀑布流布局（非 UICollectionView）
- **Service 标记 nonisolated**，避免阻塞 MainActor
- **主题色**：薄荷绿色系（Mint Green），搭配渐变效果

---

## 分批实施计划

### 第 1 批：项目基础架构

**目标**：搭建骨架，添加依赖，定义数据模型、网络层、主题色系统。App 编译运行显示主题化占位页面。

**创建文件**：
- `Info.plist` — 相机/相册/蓝牙权限 + ATS 例外（七牛 HTTP）
- `App/AppConstants.swift` — 配置常量：
  - Supabase URL: `https://wyqzgryuxyfrsenyupls.supabase.co`
  - Supabase Anon Key: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
  - 七牛 Token 服务器: `http://1.92.84.13:5177/v1/qiniu/token`
  - 七牛 CDN 域名: `http://qiniu.daxiaoxiang.com`
- `App/AppState.swift` — `@Observable` 全局状态
- `Models/` — 全部 4 个模型文件（Codable struct，snake_case CodingKeys）
- `Repositories/SupabaseClient.swift` — 单例初始化
- `Utils/` — Logger, NetworkRetry, Validators, DateFormatters, HapticFeedback
- `Extensions/` — Color+Theme, View+Extensions, Date+Formatting, String+Extensions
- `Components/` — ToastView, LoadingOverlay, GradientBackground

**修改文件**：
- `Clothing_MintApp.swift` — 注入 AppState 到 Environment
- `ContentView.swift` — 显示主题色占位界面
- `project.pbxproj` — 通过 Xcode 添加 SPM 依赖

**验证**：App 编译运行，显示主题色界面，Console 输出 Logger 日志，Supabase 客户端初始化无崩溃。

---

### 第 2 批：用户认证模块

**目标**：登录/注册/退出全流程、会话持久化、带动画的欢迎页。

**创建文件**：AuthService, AuthViewModel, SplashViewModel, LoginView, SignupView, SplashView, AppRouter

**修改文件**：ContentView（根据认证状态路由）、Clothing_MintApp（启动 auth 监听）

**验证**：启动 → 欢迎动画 → 未登录进登录页 → 登录成功进主页 → 杀进程重启保持登录 → 退出回登录页。表单验证错误正确显示。

---

### 第 3 批：主导航框架

**目标**：自定义弧形 Tab Bar + FAB，3 个 Tab 页（占位），Tab 切换动画，状态保持。

**创建文件**：MainTabView, ArcTabBar, MainTabViewModel

**设计要点**：
- 自定义 `Shape` 绘制带半圆凹槽的矩形
- 左右两个 Tab 按钮（统计/库存），中心 FAB（"+"）
- `ZStack` + `.opacity` 保持 Tab 页状态不销毁
- 选中 Tab 有渐变色 + 缩放动画

**验证**：Tab 切换正常，FAB 触发动作，Tab 页状态保持，iPhone/iPad 上弧形正确渲染。

---

### 第 4 批：库存总览

**目标**：位置/类型筛选、滚动联动统计卡片、瀑布流网格、下拉刷新、回到顶部。

**创建文件**：ClothingRepository, StatisticsRepository, DictRepository, ClothingService, DictService, StatisticsService, InventoryViewModel, InventoryOverviewView, InventoryStatsCard, WaterfallGridView, CachedAsyncImage, DropdownPicker, StatusBadge, ScrollToTopButton

**验证**：从 Supabase 加载数据 → 瀑布流显示 → 筛选过滤正常 → 统计卡片滚动折叠 → 下拉刷新 → 分页加载 → 空状态展示。

---

### 第 5 批：服装入库（创建）

**目标**：拍照/相册选图、七牛上传带进度、条码自动生成、动态下拉表单、保存到 Supabase。

**创建文件**：QiniuUploadService, BarcodeGenerator, ImagePickerView, ClothingFormViewModel, ClothingCreateView, BarcodePreviewView

**条码格式**：`YYMMDD` + 6 位随机字母数字，CoreImage `CICode128BarcodeGenerator` 渲染。

**验证**：FAB 打开表单 → 拍照/选图 → 上传进度条 → 条码自动生成 → 下拉选项从数据库加载 → 必填校验 → 保存成功绿色 Toast → 条码预览正确。

---

### 第 6 批：服装详情

**目标**：完整详情展示、上架切换、闲鱼链接、标记出库、滑动返回。

**创建文件**：ClothingDetailViewModel, ClothingDetailView

**验证**：从库存点击进详情 → 信息完整 → 切换上架状态 → 添加闲鱼链接 → 标记已售 → 滑动返回 → 更新时加载遮罩。

---

### 第 7 批：统计首页

**目标**：条码搜索、销售总额/总量、TOP3 品类、位置统计、下拉刷新。

**创建文件**：StatisticsViewModel, StatisticsHomeView

**验证**：统计数据与数据库一致 → 搜索条码/描述可定位 → TOP3 排名正确 → 位置统计准确 → 下拉刷新。

---

### 第 8 批：蓝牙打印模块

**目标**：BLE 设备扫描/连接、Code128 标签预览、多协议打印 + 重试。

**创建文件**：BLEManager, PrintProtocol + 4 种协议实现, PrinterDevice, BluetoothPrintService, PrinterViewModel, PrinterScanView, PrintLabelPreviewView

**打印流程**：HM-T → ESC/POS → TSPL → 纯文本，每协议重试 3 次，20 字节分块传输。

**验证**：扫描发现设备 → 连接/断开 → 标签预览 → 打印发送 → 蓝牙关闭提示。

---

### 第 9 批：完善与适配

**任务**：
- 错误处理审查：所有异步操作捕获错误 + 对应 Toast
- iPad 适配：瀑布流 3-4 列、统计并排布局、详情页限宽、Tab Bar 缩放
- 动画打磨：页面转场、卡片交错入场、FAB 按压、下拉刷新
- 边界情况：离线提示、空状态、长文本截断、上传失败恢复

---

### 第 10 批：CI/CD + README + 优化建议

**创建文件**：
- `.github/workflows/build.yml` — tag 触发构建，产出 IPA artifact
- `ExportOptions.plist` — 导出配置
- `README.md` — 全新专业 README（徽章、截图、架构图、技术栈、快速开始、项目结构）
- `.gitignore` — Swift/Xcode 标准忽略规则

**优化建议**（完成后提供）：
1. SwiftData 本地缓存实现离线优先体验
2. 图片 WebP 压缩减少上传体积
3. 分页预加载（80% 滚动触发）
4. Supabase Realtime 实时同步
5. Widget 小组件快速查看统计
6. Crashlytics 崩溃上报
7. Deep Link 支持条码扫描跳转

---

## 批次依赖关系

```
Batch 1 → Batch 2 → Batch 3 → Batch 4 → Batch 5 → Batch 6
                                  ↓                    ↓
                               Batch 7             Batch 8
                                  ↓                    ↓
                               Batch 9 ← ← ← ← ← ← ←
                                  ↓
                               Batch 10
```

每批完成后：人工测试 → 确认通过 → git commit → 进入下一批。
