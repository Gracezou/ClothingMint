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
        }
    }
}

#Preview {
    BarcodePreviewView(code: "260227ABC123")
}
