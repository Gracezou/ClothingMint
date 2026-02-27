# DailyMint - 智能服装库存管理系统

> 本文档描述 DailyMint 的完整功能清单与技术细节，用于指导开发 Swift 原生 iOS App。

---

## 一、应用概述

DailyMint 是一款面向个人卖家/小型商户的服装库存管理工具，提供服装入库、出库、闲鱼上架、蓝牙条码打印、销售统计等全流程管理能力。

---

## 二、功能模块清单

### 1. 用户认证

| 功能 | 说明 |
|------|------|
| 邮箱密码登录 | 表单验证（邮箱正则 + 密码非空），错误提示 |
| 用户注册 | 邮箱 + 密码创建新账号 |
| 退出登录 | 清除会话，返回登录页 |
| 会话状态监听 | 监听登录状态变化，自动跳转对应页面 |
| 欢迎页（Splash） | 启动动画（淡入、缩放、旋转、滑入），显示版本号，根据登录状态自动导航 |

**后端：** Supabase Auth

---

### 2. 主导航结构

底部导航栏（3 个 Tab + 中心悬浮按钮）：

| Tab | 页面 | 说明 |
|-----|------|------|
| Tab 0 | 统计首页 | 销售数据统计 |
| FAB（中心） | 新增服装 | 弹出创建服装表单 |
| Tab 2 | 库存总览 | 按位置/类型筛选库存 |

- 自定义弧形底部导航栏（带凹槽适配 FAB）
- 选中 Tab 有渐变色和动画效果
- 页面切换带动画过渡
- Tab 页面保持状态不销毁

---

### 3. 服装入库（创建）

| 功能 | 说明 |
|------|------|
| 拍照/相册选图 | 使用系统相机或从相册选择图片 |
| 图片上传 | 上传至七牛云 CDN，显示上传进度百分比 |
| 条码自动生成 | 格式：`YYMMDD` + 6 位随机字母数字 |
| 表单字段 | 尺码、颜色、类型（品类）、位置、价格、描述、入库日期、是否退货、退货时间 |
| 动态下拉选项 | 品类/颜色/尺码从数据库字典表动态获取 |
| 表单验证 | 必填项校验，错误提示 |
| 条码打印预览 | 保存后可预览条码标签并打印 |

---

### 4. 服装详情

| 功能 | 说明 |
|------|------|
| 详情展示 | 大图、尺码、颜色、位置、价格、入库日期、描述等完整信息 |
| 上架状态切换 | 未上架 → 已上架（标记上架状态） |
| 添加闲鱼链接 | 表单输入闲鱼商品链接和挂出价格 |
| 标记出库（已售） | 设置出库日期和实际成交价格 |
| 左滑返回手势 | 支持手势滑动返回，有速度阈值判断 |
| 更新确认提示 | Toast 通知，包含价格变动信息 |
| 加载状态遮罩 | 更新时显示半透明加载层 |

---

### 5. 库存总览

| 功能 | 说明 |
|------|------|
| 按位置筛选 | 下拉选择存放位置，筛选该位置的库存 |
| 按类型筛选 | 选中位置后显示类型标签，点击切换筛选 |
| 统计卡片 | 显示总数量、已上架数量、类型分布；随滚动折叠收缩动画 |
| 瀑布流网格 | 服装卡片展示：图片 + 尺码 + 状态徽章（上架/未上架） |
| 下拉刷新 | 重新加载数据 |
| 回到顶部按钮 | 长列表时显示浮动按钮 |
| 点击进入详情 | 卡片点击跳转服装详情页 |

---

### 6. 统计首页

| 功能 | 说明 |
|------|------|
| 条码搜索 | 输入条码快速查找服装 |
| 销售总额 | 已售服装的总收入（¥） |
| 销售总量 | 已售服装的总数量 |
| 销量 TOP3 品类 | 按售出数量排名前 3 的品类 |
| 收入 TOP3 品类 | 按收入金额排名前 3 的品类 |
| 位置统计 | 每个存放位置的库存数量及主要品类 |
| 下拉刷新 | 重新加载统计数据 |

---

### 7. 蓝牙条码打印

| 功能 | 说明 |
|------|------|
| 蓝牙设备扫描 | 发现附近蓝牙打印机设备列表 |
| 设备连接/断开 | 管理蓝牙连接状态 |
| 蓝牙状态检测 | 检查设备蓝牙是否开启 |
| 条码标签预览 | 显示 Code128 格式条码 + 尺码 + 编号 |
| 多协议打印 | 按优先级依次尝试：HM-T → ESC/POS → TSPL → 纯文本 |
| 分块传输 | 20 字节分块发送，确保蓝牙传输稳定 |
| 重试机制 | 每种协议最多重试 3 次 |

**适配打印机：** HM-T260L 系列热敏标签打印机

**打印内容：** 尺码（大字体）+ 编号（常规字体）+ Code128 条码

---

### 8. 图片管理

| 功能 | 说明 |
|------|------|
| 图片选择 | 系统相机拍照 / 相册选取 |
| 七牛云上传 | 文件上传至七牛 CDN，返回图片 URL |
| 上传进度 | 实时显示上传百分比 |
| Token 管理 | 自动获取/刷新上传凭证（2 小时有效期） |
| 图片缓存 | 网络图片本地缓存，提升加载速度 |
| 图片预览 | 支持图片全屏预览 |

---

## 三、数据模型

### ClothingInventory（服装库存）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String (UUID v4) | 唯一标识，客户端生成 |
| code | String | 条码编号（YYMMDD + 6位随机） |
| merchantId | String | 商户 ID |
| size | String | 尺码（XS ~ 6XL） |
| color | String | 颜色 |
| type | String | 品类 |
| location | String | 存放位置 |
| photoUrl | String? | 图片 URL（七牛云 CDN） |
| price | Double | 价格 |
| description | String? | 描述 |
| stockInDate | DateTime | 入库日期 |
| stockOutDate | DateTime? | 出库日期（null 表示未售） |
| xianyuLink | String? | 闲鱼链接 |
| isReturned | Bool | 是否退货 |
| returnTime | DateTime? | 退货时间 |
| createdAt | DateTime | 创建时间 |
| updatedAt | DateTime | 更新时间 |

### ClothingDictItem（字典项）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | String | 标识 |
| category | String | 分类名称（如 "type"、"color"） |
| name | String | 选项显示名称 |
| sortNo | Int | 排序序号 |

---

## 四、预设选项常量

| 类别 | 选项值 |
|------|--------|
| 尺码 | XS, S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL |
| 颜色 | 红、橙、黄、绿、蓝、紫、粉、白、灰、黑、棕（共 11 种） |
| 存放位置 | 挂衣架、收纳架、衣柜、置物架、收纳箱等（共 13 个） |

---

## 五、API 接口清单

### 5.1 服装库存服务

| 接口 | 说明 |
|------|------|
| getListClothingInventory(page, pageSize) | 分页获取库存列表（排除已售） |
| getClothingById(id) | 按 ID 获取单条记录 |
| createClothing(data) | 创建服装记录 |
| updateClothing(id, data) | 更新服装记录 |
| searchClothing(keyword) | 全文搜索（条码或描述，ILIKE 模糊匹配） |
| getClothingByLocation(location) | 按存放位置筛选 |
| searchClothingByLocation(location) | 按位置搜索（排除已售） |
| getAvailableLocations() | 获取所有在用的存放位置 |
| getAllAvailableClothing() | 获取所有未售服装 |

### 5.2 统计接口

| 接口 | 说明 |
|------|------|
| getStatistics(location?) | 统计数据：总数、已上架数、类型分布（可按位置过滤） |
| getSoldStatistics() | 销售统计：总额、数量、按品类排名 TOP3（数量和金额） |
| getLocationStatistics() | 位置统计：各位置库存数量及主要品类 |

### 5.3 字典服务

| 接口 | 说明 |
|------|------|
| getDictByType(category) | 获取指定分类的下拉选项 |
| getAllDictTypes(categories[]) | 批量获取多个分类（调用存储过程 `get_clothing_dict_by_categories`） |

### 5.4 认证服务

| 接口 | 说明 |
|------|------|
| login(email, password) | 邮箱密码登录 |
| signup(email, password) | 注册新用户 |
| logout() | 退出登录 |
| getCurrentUser() | 获取当前用户 |
| onAuthStateChange() | 监听认证状态变化 |

### 5.5 七牛云上传

| 接口 | 说明 |
|------|------|
| fetchUploadToken() | 从 Token 服务器获取上传凭证 |
| uploadFile(filePath) | 上传文件，返回 CDN URL |

**Token 服务器：** `http://1.92.84.13:5177/v1/qiniu/token`
**CDN 域名：** `http://qiniu.daxiaoxiang.com`
**上传 Key 格式：** `sampleClothing/{date}/{uuid}`

### 5.6 通用机制

- **重试机制：** 网络请求最多重试 3 次，间隔 2 秒
- **超时控制：** 30 秒超时
- **错误日志：** 分级日志（Error / Warning / Info / Debug）

---

## 六、数据库结构

### 表

| 表名 | 说明 |
|------|------|
| sample_clothing_inventory | 服装库存主表 |
| sample_clothing_dict | 品类/属性字典表 |
| auth.users | 用户认证表（Supabase 内置） |

### 存储过程

- `get_clothing_dict_by_categories(categories text[])` — 批量获取多个分类的字典数据

### 查询模式

- 分页：使用 `range(offset, limit)` 实现
- 模糊搜索：`ILIKE` + `OR`（同时搜索 code 和 description）
- 过滤已售：`stockOutDate IS NULL`
- 排序：`createdAt DESC`（默认按创建时间倒序）

---

## 七、错误处理体系

| 错误类型 | 处理方式 |
|----------|----------|
| 网络错误（超时/连接失败） | 弹出网络异常对话框，支持重试 |
| HTTP 错误（401/403/404/5xx） | SnackBar/Toast 提示对应错误信息 |
| 认证错误（密码错误/用户不存在/邮箱已注册） | 表单内提示具体错误 |
| 上传错误（七牛超时） | Toast 警告 |
| 蓝牙错误（未支持/未开启/连接失败） | 提示开启蓝牙或重试连接 |

**反馈 UI 样式：**
- 成功：绿色 Toast
- 警告：橙色 Toast
- 错误：红色 Toast
- 信息：蓝色 Toast

**异步重试机制：**
- 最多 3 次重试，2 秒间隔
- 网络错误自动识别
- 30 秒超时
- 重试过程中向用户展示进度

---

## 八、UI/UX 特性

| 特性 | 说明 | Swift 实现建议 |
|------|------|---------------|
| 渐变背景 | 登录页、欢迎页使用线性渐变 | CAGradientLayer / LinearGradient |
| 启动动画 | 淡入、缩放、旋转、滑入组合 | UIView.animate / withAnimation |
| 滚动联动动画 | 总览页统计卡片随滚动缩放折叠 | UIScrollViewDelegate / ScrollView offset |
| 触觉反馈 | 按钮点击时轻/中等振动 | UIImpactFeedbackGenerator |
| 瀑布流布局 | 库存网格使用交错网格 | UICollectionViewCompositionalLayout |
| 弧形导航栏 | 自定义带 FAB 凹槽的底部导航 | UIBezierPath + CAShapeLayer |
| 状态徽章 | 卡片上的上架/未上架标签 | 自定义 UILabel / SwiftUI overlay |
| 左滑返回手势 | 详情页手势返回 | UIScreenEdgePanGestureRecognizer |
| 下拉刷新 | 所有列表页支持 | UIRefreshControl |
| 加载遮罩 | 异步操作时半透明加载层 | 自定义 ProgressHUD |

---

## 九、路由定义

| 路径 | 页面 | 参数 |
|------|------|------|
| `/` | 主布局（底部导航） | - |
| `/welcome` | 欢迎页 | - |
| `/login` | 登录页 | - |
| `/clothing_detail` | 服装详情 | id: String 或完整对象 |
| `/statistics` | 统计页 | - |
| `/overview` | 库存总览 | - |

---

## 十、第三方服务与 Swift 替代方案

| 服务 | 当前用途 | Swift 原生替代方案 |
|------|----------|-------------------|
| Supabase | 认证 + PostgreSQL 数据库 | [supabase-swift](https://github.com/supabase/supabase-swift) SDK |
| 七牛云 | 图片 CDN 存储与上传 | [QiniuSDK-iOS](https://github.com/qiniu/objc-sdk) 或 HTTP 直传 |
| 蓝牙通信 | 打印机连接与数据传输 | CoreBluetooth 框架 |
| 图片选取 | 相机 / 相册 | PhotosUI (PHPickerViewController) / UIImagePickerController |
| 条码生成 | Code128 条码渲染 | CoreImage CIFilter (CICode128BarcodeGenerator) |
| 图片缓存 | 网络图片本地缓存 | Kingfisher / SDWebImage / URLCache |
| 瀑布流布局 | 交错网格 | UICollectionViewCompositionalLayout |
| 日期格式化 | 多语言日期 | Foundation DateFormatter |
| UUID 生成 | 唯一标识 | Foundation UUID |
| HTTP 请求 | Token 获取等 | URLSession |

---

## 十一、架构模式

| 层 | 职责 | Swift 建议 |
|----|------|-----------|
| UI 层 | 页面与组件渲染 | SwiftUI View / UIKit ViewController |
| 服务层（Service） | 业务逻辑、API 调用封装 | Service 类，async/await |
| 数据层（Repository） | Supabase 数据访问 | Repository 协议 + 实现 |
| 模型层（Model） | 数据结构定义 | Codable struct |
| 工具层（Utils） | 错误处理、上传管理等 | 工具类 / extension |

**状态管理：** 局部状态 + 页面间回调/路由参数传递（Swift 中可用 @State/@ObservedObject 或 Combine）

---

## 十二、蓝牙打印协议详情

打印机通过 BLE 连接，按以下优先级尝试协议：

### 协议 1：HM-T 协议（HM-T260L 专用）
- 初始化命令 + 标签尺寸设置
- 大字体打印尺码
- 常规字体打印编号
- Code128 条码 + HRI 文本

### 协议 2：ESC/POS 协议
- 标准热敏打印机指令集
- 文本对齐、字体大小控制
- 条码打印指令

### 协议 3：TSPL 协议
- 标签打印机通用协议
- SIZE、GAP、CLS、TEXT、BARCODE 指令

### 协议 4：纯文本
- 兜底方案，直接发送文本内容

**传输参数：**
- 分块大小：20 字节
- 块间延迟：确保打印机处理完成
- 重试次数：每协议 3 次
