//
//  ArcTabBar.swift
//  Clothing Mint
//
//  自定义弧形底部导航栏，带中心凹槽适配 FAB
//

import SwiftUI

/// 弧形凹槽形状
struct ArcTabBarShape: Shape {
    /// 凹槽半径
    var notchRadius: CGFloat = 35

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let notchDepth: CGFloat = notchRadius * 0.7

        // 从左上角开始
        path.move(to: CGPoint(x: 0, y: 0))

        // 顶部左侧直线
        path.addLine(to: CGPoint(x: midX - notchRadius - 10, y: 0))

        // 凹槽左侧曲线
        path.addCurve(
            to: CGPoint(x: midX - notchRadius + 5, y: notchDepth),
            control1: CGPoint(x: midX - notchRadius, y: 0),
            control2: CGPoint(x: midX - notchRadius, y: notchDepth)
        )

        // 凹槽底部圆弧
        path.addArc(
            center: CGPoint(x: midX, y: notchDepth),
            radius: notchRadius - 5,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )

        // 凹槽右侧曲线
        path.addCurve(
            to: CGPoint(x: midX + notchRadius + 10, y: 0),
            control1: CGPoint(x: midX + notchRadius, y: notchDepth),
            control2: CGPoint(x: midX + notchRadius, y: 0)
        )

        // 顶部右侧直线
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))

        // 底部
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

/// Tab 项定义
struct TabItem {
    let title: String
    let icon: String
    let selectedIcon: String
}

/// 弧形 Tab Bar 视图
struct ArcTabBar: View {
    @Binding var selectedTab: Int
    let onFABTapped: () -> Void

    /// Tab 定义
    private let tabs: [TabItem] = [
        TabItem(title: "统计", icon: "chart.bar", selectedIcon: "chart.bar.fill"),
        TabItem(title: "库存", icon: "archivebox", selectedIcon: "archivebox.fill")
    ]

    var body: some View {
        ZStack(alignment: .top) {
            // 弧形背景
            ArcTabBarShape()
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
                .frame(height: 60)

            // Tab 按钮
            HStack {
                // 左侧 Tab（统计）
                tabButton(index: 0)

                Spacer()

                // 右侧 Tab（库存）
                tabButton(index: 1)
            }
            .padding(.horizontal, 32)
            .padding(.top, 8)

            // 中心 FAB 按钮
            fabButton
                .offset(y: -26)
        }
    }

    // MARK: - Tab 按钮

    private func tabButton(index: Int) -> some View {
        Button {
            withAnimation(.spring(duration: 0.3)) {
                selectedTab = index
            }
            HapticFeedback.light()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == index ? tabs[index].selectedIcon : tabs[index].icon)
                    .font(.system(size: 22))
                    .scaleEffect(selectedTab == index ? 1.1 : 1.0)

                Text(tabs[index].title)
                    .font(.caption2)
            }
            .foregroundStyle(
                selectedTab == index ? Color.mintPrimary : .secondary
            )
            .frame(width: 64)
        }
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button {
            onFABTapped()
            HapticFeedback.medium()
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.mintGradient)
                        .shadow(color: Color.mintPrimary.opacity(0.4), radius: 8, y: 4)
                )
        }
    }
}

#Preview {
    VStack {
        Spacer()
        ArcTabBar(selectedTab: .constant(0)) {}
    }
}
