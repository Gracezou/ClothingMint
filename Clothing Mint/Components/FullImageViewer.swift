//
//  FullImageViewer.swift
//  Clothing Mint
//
//  全屏图片预览：支持双指缩放、双击放大/还原、下拉关闭
//

import SwiftUI
import Kingfisher

/// 全屏图片预览视图
struct FullImageViewer: View {
    let url: String
    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var dragOffset: CGSize = .zero

    /// 背景透明度（随下拉距离变化）
    private var backgroundOpacity: Double {
        let progress = abs(dragOffset.height) / 300
        return max(1 - progress, 0.3)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            if let imageURL = URL(string: url) {
                KFImage(imageURL)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(x: offset.width + dragOffset.width,
                            y: offset.height + dragOffset.height)
                    .gesture(magnificationGesture)
                    .gesture(scale <= 1 ? dragToCloseGesture : nil)
                    .gesture(scale > 1 ? panGesture : nil)
                    .onTapGesture(count: 2) { doubleTap() }
            }

            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
        .statusBar(hidden: true)
    }

    // MARK: - 手势

    /// 双指缩放
    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newScale = lastScale * value.magnification
                scale = min(max(newScale, 0.5), 5.0)
            }
            .onEnded { _ in
                withAnimation(.spring(duration: 0.3)) {
                    if scale < 1 {
                        scale = 1
                        offset = .zero
                    }
                }
                lastScale = scale
                lastOffset = offset
            }
    }

    /// 下拉关闭（仅原始尺寸时）
    private var dragToCloseGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                if abs(value.translation.height) > 120 {
                    dismiss()
                } else {
                    withAnimation(.spring(duration: 0.3)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    /// 放大后平移
    private var panGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    /// 双击放大/还原
    private func doubleTap() {
        withAnimation(.spring(duration: 0.3)) {
            if scale > 1 {
                scale = 1
                lastScale = 1
                offset = .zero
                lastOffset = .zero
            } else {
                scale = 2.5
                lastScale = 2.5
            }
        }
    }
}
