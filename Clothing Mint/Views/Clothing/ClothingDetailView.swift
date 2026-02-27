//
//  ClothingDetailView.swift
//  Clothing Mint
//
//  服装详情页：完整信息展示、上架切换、闲鱼链接、标记出库/退货
//

import SwiftUI

/// 服装详情视图
struct ClothingDetailView: View {
    let clothingId: String
    @State private var viewModel: ClothingDetailViewModel
    @Environment(\.dismiss) private var dismiss

    /// 确认操作弹窗
    @State private var showSoldConfirm = false
    @State private var showReturnConfirm = false

    init(clothingId: String) {
        self.clothingId = clothingId
        _viewModel = State(initialValue: ClothingDetailViewModel(clothingId: clothingId))
    }

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            if viewModel.isLoading && viewModel.clothing == nil {
                ProgressView("加载中...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let clothing = viewModel.clothing {
                ScrollView {
                    VStack(spacing: 16) {
                        // 图片
                        photoSection(clothing)

                        // 条码
                        barcodeSection(clothing)

                        // 基本信息
                        infoSection(clothing)

                        // 状态信息
                        statusSection(clothing)

                        // 闲鱼链接
                        xianyuSection(clothing)

                        // 操作按钮
                        if !clothing.isSold {
                            actionSection(clothing)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(16)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("无法加载详情")
                        .foregroundStyle(.secondary)
                }
            }

            // 更新遮罩
            if viewModel.isUpdating {
                LoadingOverlay()
            }
        }
        .navigationTitle("服装详情")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresented: $viewModel.showToast, type: viewModel.toastType, message: viewModel.toastMessage)
        .alert("确认售出", isPresented: $showSoldConfirm) {
            Button("确认", role: .destructive) {
                Task { await viewModel.markAsSold() }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("标记为已售出后，该商品将从库存中移除")
        }
        .alert("确认退货", isPresented: $showReturnConfirm) {
            Button("确认", role: .destructive) {
                Task { await viewModel.markAsReturned() }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("确认标记该商品为退货？")
        }
        .sheet(isPresented: $viewModel.showLinkEditor) {
            linkEditorSheet
        }
        .task {
            await viewModel.loadDetail()
        }
    }

    // MARK: - 图片区域

    private func photoSection(_ clothing: ClothingInventory) -> some View {
        ZStack(alignment: .topTrailing) {
            if let url = clothing.fullPhotoUrl {
                CachedAsyncImage(url: url, placeholder: "tshirt")
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
            } else {
                ZStack {
                    Color.cardBackground
                    Image(systemName: "tshirt")
                        .font(.system(size: 60))
                        .foregroundStyle(.gray.opacity(0.3))
                }
                .frame(height: 200)
            }

            // 状态角标
            VStack(spacing: 6) {
                if clothing.isSold {
                    statusChip(text: "已售出", color: .orange)
                }
                if clothing.isReturned {
                    statusChip(text: "已退货", color: .red)
                }
                if clothing.isListed {
                    statusChip(text: "已上架", color: .green)
                }
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statusChip(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(color))
    }

    // MARK: - 条码区域

    private func barcodeSection(_ clothing: ClothingInventory) -> some View {
        VStack(spacing: 8) {
            if let barcodeImage = BarcodeGenerator.generateBarcodeImage(code: clothing.code, width: 350, height: 70) {
                barcodeImage
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
            }

            Text(clothing.code)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 基本信息

    private func infoSection(_ clothing: ClothingInventory) -> some View {
        VStack(spacing: 0) {
            sectionTitle("基本信息")

            VStack(spacing: 0) {
                infoRow(label: "类型", value: clothing.type)
                Divider().padding(.leading, 16)
                infoRow(label: "尺码", value: clothing.size)
                Divider().padding(.leading, 16)
                infoRow(label: "颜色", value: clothing.color)
                Divider().padding(.leading, 16)
                infoRow(label: "位置", value: clothing.location)
                Divider().padding(.leading, 16)
                infoRow(label: "价格", value: "¥\(String(format: "%.0f", clothing.price))")

                if let desc = clothing.description, !desc.isEmpty {
                    Divider().padding(.leading, 16)
                    infoRow(label: "描述", value: desc)
                }
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 状态信息

    private func statusSection(_ clothing: ClothingInventory) -> some View {
        VStack(spacing: 0) {
            sectionTitle("时间记录")

            VStack(spacing: 0) {
                infoRow(label: "入库日期", value: clothing.displayStockInDate)

                if let outDate = clothing.displayStockOutDate {
                    Divider().padding(.leading, 16)
                    infoRow(label: "出库日期", value: outDate)
                }

                Divider().padding(.leading, 16)
                infoRow(label: "创建时间", value: clothing.displayCreatedAt)

                if clothing.isReturned, let returnTime = clothing.returnTime {
                    Divider().padding(.leading, 16)
                    infoRow(label: "退货时间", value: String(returnTime.prefix(10)))
                }
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 闲鱼链接区域

    private func xianyuSection(_ clothing: ClothingInventory) -> some View {
        VStack(spacing: 0) {
            sectionTitle("闲鱼信息")

            VStack(spacing: 0) {
                HStack {
                    Text("闲鱼链接")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    if let link = clothing.xianyuLink, !link.isEmpty {
                        Text(link)
                            .font(.caption)
                            .foregroundStyle(Color.mintPrimary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: 180, alignment: .trailing)
                    } else {
                        Text("未上架")
                            .font(.subheadline)
                            .foregroundStyle(.secondary.opacity(0.6))
                    }
                }
                .padding(16)

                Divider().padding(.leading, 16)

                // 编辑按钮
                Button {
                    viewModel.xianyuLinkInput = clothing.xianyuLink ?? ""
                    viewModel.showLinkEditor = true
                } label: {
                    HStack {
                        Image(systemName: clothing.isListed ? "pencil" : "link.badge.plus")
                            .font(.subheadline)
                        Text(clothing.isListed ? "修改链接" : "添加闲鱼链接")
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.mintPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
            }
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 操作按钮

    private func actionSection(_ clothing: ClothingInventory) -> some View {
        VStack(spacing: 12) {
            // 标记售出
            Button {
                showSoldConfirm = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "bag.fill")
                    Text("标记已售出")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.mintGradient)
                )
            }

            // 标记退货
            if !clothing.isReturned {
                Button {
                    showReturnConfirm = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.uturn.backward")
                        Text("标记退货")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - 闲鱼链接编辑 Sheet

    private var linkEditorSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("输入闲鱼商品链接，留空则下架")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField("https://...", text: $viewModel.xianyuLinkInput)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)

                Button {
                    Task { await viewModel.saveXianyuLink() }
                } label: {
                    Text("保存")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.mintGradient)
                        )
                }
                .disabled(viewModel.isUpdating)

                Spacer()
            }
            .padding(20)
            .navigationTitle("闲鱼链接")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { viewModel.showLinkEditor = false }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - 辅助视图

    private func sectionTitle(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.bottom, 6)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
    }
}

#Preview {
    NavigationStack {
        ClothingDetailView(clothingId: "preview-id")
    }
    .environment(AppState())
}
