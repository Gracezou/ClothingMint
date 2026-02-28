# Changelog

## [1.0.0] - 2025-02-28

### 功能

- **用户认证**：邮箱密码登录/注册，会话自动持久化
- **库存总览**：瀑布流展示、位置/类型独立筛选、统计卡片、分页预加载、下拉刷新、回到顶部
- **服装入库**：拍照/选图上传七牛云、图片自适应压缩（≤1920×1080）、条码自动生成（Code128）、动态表单验证
- **服装详情**：完整信息展示、全屏图片预览、闲鱼链接管理、标记售出/退货
- **图片管理**：七牛 CDN 多级缩略图（300px/600px/原图）、Kingfisher 缓存（200MB 磁盘 / 100MB 内存）
- **统计分析**：销售总额/总量、TOP3 品类排行、位置库存分布、条码搜索
- **蓝牙打印**：BLE 设备扫描连接（10s 超时）、多协议自动切换（HM-T/ESC-POS/TSPL/PlainText）、20 字节分块传输 + 写入回调确认
- **实时同步**：Supabase Realtime 监听数据变更、自动重连（最多 5 次）
- **iPad 适配**：响应式布局、瀑布流自适应列数（2/3 列）、限宽居中
- **Deep Link**：`clothingmint://detail/{id}` 跳转服装详情
- **CI/CD**：GitHub Actions 自动构建 + IPA 产出

### 技术栈

- Swift 6 + SwiftUI (iOS 26+)
- @Observable 状态管理
- Supabase (Auth + PostgREST + Realtime)
- Kingfisher 8.x 图片缓存
- CoreBluetooth BLE
- CoreImage 条码生成

### 已知限制

- 蓝牙打印功能需要真机测试，模拟器不支持 CoreBluetooth
- 七牛 CDN 域名 `qiniu2.daxiaoxiang.com` 需内网可达
- Token 服务 `124.71.145.245:5177` 需网络可达
- 使用 HTTP（ATS 例外）访问七牛 CDN 和 Token 服务
- 桌面小组件功能为基础实现，后续版本完善
