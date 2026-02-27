//
//  PrinterScanView.swift
//  Clothing Mint
//
//  蓝牙打印机扫描/连接页面
//

import SwiftUI

/// 打印机扫描视图
struct PrinterScanView: View {
    @State private var viewModel = PrinterViewModel()
    let clothing: ClothingInventory
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageBackground.ignoresSafeArea()

                VStack(spacing: 16) {
                    // 连接状态
                    connectionStatusCard

                    // 标签预览
                    labelPreviewCard

                    // 设备列表 / 打印按钮
                    if case .connected = viewModel.bleManager.connectionState {
                        printSection
                    } else {
                        deviceListSection
                    }

                    Spacer()
                }
                .padding(16)
            }
            .navigationTitle("蓝牙打印")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .toast(isPresented: $viewModel.showToast, type: viewModel.toastType, message: viewModel.toastMessage)
            .onAppear {
                viewModel.startScan()
            }
            .onDisappear {
                viewModel.stopScan()
            }
        }
    }

    // MARK: - 连接状态卡片

    private var connectionStatusCard: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon)
                .font(.title2)
                .foregroundStyle(statusColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(statusTitle)
                    .font(.subheadline.bold())

                Text(statusSubtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 操作按钮
            if case .connected = viewModel.bleManager.connectionState {
                Button("断开") {
                    viewModel.disconnect()
                }
                .font(.caption)
                .foregroundStyle(.red)
            } else if case .scanning = viewModel.bleManager.connectionState {
                ProgressView()
                    .scaleEffect(0.8)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusIcon: String {
        switch viewModel.bleManager.connectionState {
        case .connected: "checkmark.circle.fill"
        case .scanning: "antenna.radiowaves.left.and.right"
        case .connecting: "arrow.triangle.2.circlepath"
        case .error: "exclamationmark.triangle.fill"
        case .disconnected: "antenna.radiowaves.left.and.right.slash"
        }
    }

    private var statusColor: Color {
        switch viewModel.bleManager.connectionState {
        case .connected: .green
        case .scanning: Color.mintPrimary
        case .connecting: .orange
        case .error: .red
        case .disconnected: .secondary
        }
    }

    private var statusTitle: String {
        switch viewModel.bleManager.connectionState {
        case .connected: "已连接"
        case .scanning: "扫描中..."
        case .connecting: "连接中..."
        case .error(let msg): "错误: \(msg)"
        case .disconnected: "未连接"
        }
    }

    private var statusSubtitle: String {
        if let device = viewModel.bleManager.connectedDevice {
            return device.name
        }
        return viewModel.bleManager.bluetoothEnabled ? "请选择打印机" : "请确保蓝牙已开启"
    }

    // MARK: - 标签预览卡片

    private var labelPreviewCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("标签预览")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
            }

            VStack(spacing: 8) {
                // 条码
                if let barcodeImage = BarcodeGenerator.generateBarcodeImage(code: clothing.code, width: 300, height: 60) {
                    barcodeImage
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 45)
                }

                Text(clothing.code)
                    .font(.system(.caption, design: .monospaced))

                Divider()

                HStack {
                    Text("\(clothing.type) / \(clothing.size) / \(clothing.color)")
                        .font(.caption)
                    Spacer()
                    Text("¥\(String(format: "%.0f", clothing.price))")
                        .font(.caption.bold())
                        .foregroundStyle(Color.mintPrimary)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4]))
            )
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 设备列表

    private var deviceListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("发现的设备")
                    .font(.subheadline.bold())

                Spacer()

                if case .disconnected = viewModel.bleManager.connectionState {
                    Button {
                        viewModel.startScan()
                    } label: {
                        Label("重新扫描", systemImage: "arrow.clockwise")
                            .font(.caption)
                            .foregroundStyle(Color.mintPrimary)
                    }
                }
            }

            if viewModel.bleManager.discoveredDevices.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "printer.dotmatrix")
                        .font(.title)
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("未发现设备")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("请确保打印机已开机且在蓝牙范围内")
                        .font(.caption2)
                        .foregroundStyle(.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(viewModel.bleManager.discoveredDevices) { device in
                    Button {
                        viewModel.connect(to: device)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "printer.fill")
                                .foregroundStyle(Color.mintPrimary)
                            Text(device.name)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    // MARK: - 打印区域

    private var printSection: some View {
        VStack(spacing: 16) {
            Button {
                Task { await viewModel.printLabel(clothing: clothing) }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isPrinting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "printer.fill")
                    }
                    Text(viewModel.isPrinting ? "打印中..." : "开始打印")
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
            .disabled(viewModel.isPrinting)

            // 打印结果
            if let success = viewModel.printSuccess {
                HStack(spacing: 6) {
                    Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(success ? "打印完成" : "打印失败，请重试")
                }
                .font(.caption)
                .foregroundStyle(success ? .green : .red)
            }
        }
    }
}

#Preview {
    PrinterScanView(clothing: ClothingInventory(
        id: "preview",
        code: "260227ABC123",
        size: "M",
        color: "白色",
        type: "T恤",
        location: "A区",
        price: 99,
        stockInDate: "2026-02-27",
        isReturned: false,
        createdAt: "2026-02-27",
        updatedAt: "2026-02-27"
    ))
}
