//
//  BarcodePreviewView.swift
//  Clothing Mint
//
//  条码预览页面，入库成功后展示条码、支持继续新增或关闭
//

import SwiftUI

/// 条码预览视图
struct BarcodePreviewView: View {
    let code: String
    @Environment(\.dismiss) private var dismiss
    @State private var showPrinter = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.pageBackground.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // 成功图标
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.green)

                    Text("入库成功")
                        .font(.title2.bold())

                    // 条码卡片
                    VStack(spacing: 16) {
                        if let barcodeImage = BarcodeGenerator.generateBarcodeImage(code: code, width: 400, height: 100) {
                            barcodeImage
                                .interpolation(.none)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                        }

                        Text(code)
                            .font(.system(.title3, design: .monospaced))
                            .foregroundStyle(.primary)

                        Text("请妥善保管此条码，用于后续查找和打印标签")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

                    Spacer()

                    // 操作按钮
                    VStack(spacing: 12) {
                        Button {
                            showPrinter = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "printer.fill")
                                Text("打印标签")
                                    .font(.headline)
                            }
                            .foregroundStyle(Color.mintPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.mintPrimary, lineWidth: 1.5)
                            )
                        }

                        Button {
                            dismiss()
                        } label: {
                            Text("完成")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.mintGradient)
                                )
                        }
                    }
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .sheet(isPresented: $showPrinter) {
                PrinterScanView(clothing: makePrintClothing())
            }
        }
    }

    /// 构造用于打印的最小 ClothingInventory
    private func makePrintClothing() -> ClothingInventory {
        let now = DateFormatters.iso8601.string(from: .now)
        return ClothingInventory(
            id: "", code: code, merchantId: nil,
            size: "", color: "", type: "", location: "",
            photoUrl: nil, price: 0, description: nil,
            stockInDate: now, stockOutDate: nil, xianyuLink: nil,
            isReturned: false, returnTime: nil,
            createdAt: now, updatedAt: now, userId: nil
        )
    }
}

#Preview {
    BarcodePreviewView(code: "260227ABC123")
}
