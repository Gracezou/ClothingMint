//
//  ClothingCreateView.swift
//  Clothing Mint
//
//  服装入库表单页面：拍照/选图、七牛上传、条码生成、动态下拉表单
//

import SwiftUI

/// 服装入库表单
struct ClothingCreateView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var viewModel = ClothingFormViewModel()

    /// 图片选择来源
    @State private var showImageSourceSheet = false
    @State private var imageSource: ImageSourceType = .camera
    @State private var showImagePicker = false

    /// 条码预览
    @State private var showBarcodePreview = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 图片区域
                        photoSection

                        // 上传进度
                        if viewModel.isUploading {
                            uploadProgressBar
                        }

                        // 条码区域
                        barcodeSection

                        // 表单字段
                        formSection

                        // 保存按钮
                        saveButton
                    }
                    .padding(16)
                    .frame(maxWidth: 600) // iPad 限宽
                    .frame(maxWidth: .infinity) // 居中
                }

                // 保存 loading 遮罩
                if viewModel.isSaving {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("正在入库...")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .navigationTitle("新增服装")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .toast(isPresented: $viewModel.showToast, type: viewModel.toastType, message: viewModel.toastMessage)
            .confirmationDialog("选择图片来源", isPresented: $showImageSourceSheet) {
                Button("拍照") {
                    imageSource = .camera
                    showImagePicker = true
                }
                Button("从相册选择") {
                    imageSource = .photoLibrary
                    showImagePicker = true
                }
                Button("取消", role: .cancel) {}
            }
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePickerView(sourceType: imageSource, selectedImage: $viewModel.selectedImage)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showBarcodePreview, onDismiss: {
                viewModel.resetForm()
            }) {
                BarcodePreviewView(code: viewModel.savedBarcode ?? viewModel.code)
            }
            .task {
                await viewModel.loadOptions()
            }
            .onChange(of: viewModel.saveSuccess) { _, success in
                if success {
                    showBarcodePreview = true
                }
            }
        }
    }

    // MARK: - 图片区域

    private var photoSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "商品照片", icon: "camera.fill")

            Button {
                showImageSourceSheet = true
            } label: {
                Group {
                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(Color.mintPrimary.opacity(0.6))

                            Text("点击拍照或选择图片")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                    }
                }
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            viewModel.selectedImage != nil ? Color.mintPrimary.opacity(0.3) : Color.gray.opacity(0.2),
                            style: viewModel.selectedImage != nil ? StrokeStyle(lineWidth: 1) : StrokeStyle(lineWidth: 1, dash: [6])
                        )
                )
            }
            .buttonStyle(.plain)

            // 已上传标识
            if viewModel.uploadedPhotoKey != nil {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Text("图片已上传")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
        }
    }

    // MARK: - 上传进度条

    private var uploadProgressBar: some View {
        VStack(spacing: 6) {
            ProgressView(value: viewModel.uploadProgress)
                .tint(Color.mintPrimary)

            Text("上传中 \(Int(viewModel.uploadProgress * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - 条码区域

    private var barcodeSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "条码信息", icon: "barcode")

            VStack(spacing: 8) {
                // 条码图片
                if let barcodeImage = BarcodeGenerator.generateBarcodeImage(code: viewModel.code) {
                    barcodeImage
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                }

                // 条码编号
                Text(viewModel.code)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.primary)

                // 重新生成按钮
                Button {
                    viewModel.regenerateBarcode()
                } label: {
                    Label("重新生成", systemImage: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(Color.mintPrimary)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 表单区域

    private var formSection: some View {
        VStack(spacing: 12) {
            sectionHeader(title: "服装信息", icon: "tshirt.fill")

            VStack(spacing: 16) {
                // 类型
                formPicker(title: "类型", selection: $viewModel.selectedType, options: viewModel.typeOptions)

                Divider()

                // 尺码
                formPicker(title: "尺码", selection: $viewModel.selectedSize, options: viewModel.sizeOptions)

                Divider()

                // 颜色
                formPicker(title: "颜色", selection: $viewModel.selectedColor, options: viewModel.colorOptions)

                Divider()

                // 位置
                formPicker(title: "存放位置", selection: $viewModel.selectedLocation, options: viewModel.locationOptions)

                Divider()

                // 价格
                HStack {
                    Text("价格")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .leading)

                    HStack(spacing: 4) {
                        Text("¥")
                            .foregroundStyle(.secondary)
                        TextField("输入价格", text: $viewModel.price)
                            .keyboardType(.decimalPad)
                    }
                }

                Divider()

                // 入库日期
                HStack {
                    Text("入库日期")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .leading)

                    DatePicker("", selection: $viewModel.stockInDate, displayedComponents: .date)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "zh_CN"))

                    Spacer()
                }

                Divider()

                // 描述
                HStack(alignment: .top) {
                    Text("描述")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(width: 80, alignment: .leading)
                        .padding(.top, 8)

                    TextField("可选描述", text: $viewModel.description, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - 保存按钮

    private var saveButton: some View {
        Button {
            Task {
                await viewModel.save(userId: appState.currentUserId)
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
                Text(viewModel.isSaving ? "保存中..." : "确认入库")
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
        .disabled(viewModel.isSaving || viewModel.isUploading)
        .opacity(viewModel.isSaving || viewModel.isUploading ? 0.6 : 1)
        .padding(.top, 8)
    }

    // MARK: - 辅助视图

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color.mintPrimary)
            Text(title)
                .font(.subheadline.bold())
            Spacer()
        }
    }

    private func formPicker(title: String, selection: Binding<String>, options: [String]) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .leading)

            if options.isEmpty {
                if viewModel.loadOptionsFailed {
                    Button {
                        Task { await viewModel.loadOptions() }
                    } label: {
                        Label("加载失败，点击重试", systemImage: "arrow.clockwise")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } else {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            } else {
                Picker(title, selection: selection) {
                    Text("请选择").tag("")
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.menu)
                .tint(selection.wrappedValue.isEmpty ? .secondary : Color.mintPrimary)
            }

            Spacer()
        }
    }
}

#Preview {
    ClothingCreateView()
        .environment(AppState())
}
