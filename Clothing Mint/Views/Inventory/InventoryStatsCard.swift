//
//  InventoryStatsCard.swift
//  Clothing Mint
//
//  库存统计卡片，随滚动折叠收缩
//

import SwiftUI

/// 库存统计卡片
struct InventoryStatsCard: View {
    let statistics: OverviewStatistics
    var collapsed: Bool = false

    var body: some View {
        VStack(spacing: collapsed ? 8 : 14) {
            // 数量统计行
            HStack(spacing: 20) {
                statItem(title: "总数量", value: "\(statistics.totalCount)", icon: "archivebox.fill")
                statItem(title: "已上架", value: "\(statistics.listedCount)", icon: "tag.fill")

                if !collapsed {
                    statItem(title: "未上架", value: "\(statistics.totalCount - statistics.listedCount)", icon: "tag")
                }
            }

            // 类型分布（展开时显示）
            if !collapsed && !statistics.typeDistribution.isEmpty {
                Divider()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(statistics.typeDistribution.sorted(by: { $0.value > $1.value }), id: \.key) { type, count in
                            HStack(spacing: 4) {
                                Text(type)
                                    .font(.caption)
                                Text("\(count)")
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.mintPrimary)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(Color.mintPrimary.opacity(0.08))
                            )
                        }
                    }
                }
            }
        }
        .padding(collapsed ? 12 : 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
        .animation(.spring(duration: 0.3), value: collapsed)
    }

    private func statItem(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(collapsed ? .caption : .body)
                .foregroundStyle(Color.mintPrimary)

            Text(value)
                .font(collapsed ? .subheadline.bold() : .title3.bold())

            if !collapsed {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
