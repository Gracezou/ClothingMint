//
//  InventoryWidget.swift
//  Clothing Mint
//
//  Widget 小组件代码（需要在 Xcode 中添加 Widget Extension target 后集成）
//
//  使用方式：
//  1. Xcode → File → New → Target → Widget Extension
//  2. 将此文件内容复制到生成的 Widget 文件中
//  3. 共享 AppConstants 和 Models 给 Widget target
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct InventoryEntry: TimelineEntry {
    let date: Date
    let totalCount: Int
    let listedCount: Int
    let soldCount: Int
}

// MARK: - Timeline Provider

struct InventoryTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> InventoryEntry {
        InventoryEntry(date: .now, totalCount: 0, listedCount: 0, soldCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (InventoryEntry) -> Void) {
        let entry = InventoryEntry(date: .now, totalCount: 42, listedCount: 15, soldCount: 8)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InventoryEntry>) -> Void) {
        // 实际实现中通过 Supabase 获取数据
        // Widget 中建议使用 App Group 共享 UserDefaults 来传递数据
        let entry = InventoryEntry(date: .now, totalCount: 0, listedCount: 0, soldCount: 0)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget View

struct InventoryWidgetView: View {
    var entry: InventoryEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        default:
            mediumWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "tshirt.fill")
                    .foregroundStyle(Color(hue: 0.44, saturation: 0.81, brightness: 0.78))
                Text("库存")
                    .font(.headline)
            }

            Text("\(entry.totalCount)")
                .font(.system(size: 36, weight: .bold))

            Text("已上架 \(entry.listedCount) 件")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var mediumWidget: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "tshirt.fill")
                        .foregroundStyle(Color(hue: 0.44, saturation: 0.81, brightness: 0.78))
                    Text("Clothing Mint")
                        .font(.headline)
                }

                Spacer()

                Text("库存概况")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 16) {
                statColumn(title: "库存", value: entry.totalCount, color: .blue)
                statColumn(title: "上架", value: entry.listedCount, color: .green)
                statColumn(title: "已售", value: entry.soldCount, color: .orange)
            }
        }
        .padding()
    }

    private func statColumn(title: String, value: Int, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}
