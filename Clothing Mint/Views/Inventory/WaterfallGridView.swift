//
//  WaterfallGridView.swift
//  Clothing Mint
//
//  瀑布流网格布局，使用 SwiftUI Layout 协议
//

import SwiftUI

/// 瀑布流布局
struct WaterfallLayout: Layout {
    var columns: Int = 2
    var spacing: CGFloat = 12

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        let columnHeights = calculateLayout(width: width, subviews: subviews)
        let maxHeight = columnHeights.max() ?? 0
        return CGSize(width: width, height: maxHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let columnWidth = (bounds.width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var columnHeights = Array(repeating: CGFloat(0), count: columns)

        for subview in subviews {
            // 放入最矮的列
            guard let columnIndex = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset else { continue }
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))

            let x = bounds.minX + CGFloat(columnIndex) * (columnWidth + spacing)
            let y = bounds.minY + columnHeights[columnIndex]

            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(width: columnWidth, height: size.height))

            columnHeights[columnIndex] += size.height + spacing
        }
    }

    private func calculateLayout(width: CGFloat, subviews: Subviews) -> [CGFloat] {
        let columnWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        var columnHeights = Array(repeating: CGFloat(0), count: columns)

        for subview in subviews {
            guard let columnIndex = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset else { continue }
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
            columnHeights[columnIndex] += size.height + spacing
        }

        return columnHeights
    }
}

/// 服装卡片视图
struct ClothingCard: View {
    let item: ClothingInventory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(url: item.thumbnailUrl, placeholder: "tshirt")

                StatusBadge(isListed: item.isListed)
                    .padding(8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipped()

            // 信息
            VStack(alignment: .leading, spacing: 4) {
                Text(item.type)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                HStack {
                    Text(item.size)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(Color.mintPrimary.opacity(0.1))
                        )

                    Text(item.color)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("¥\(item.price, specifier: "%.0f")")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color.mintPrimary)
            }
            .padding(10)
        }
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .drawingGroup()
    }
}
