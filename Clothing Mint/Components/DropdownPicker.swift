//
//  DropdownPicker.swift
//  Clothing Mint
//
//  可复用的下拉选择器
//

import SwiftUI

/// 下拉选择器
struct DropdownPicker: View {
    let title: String
    let options: [String]
    @Binding var selection: String?
    var showAllOption = true

    var body: some View {
        Menu {
            if showAllOption {
                Button {
                    selection = nil
                } label: {
                    HStack {
                        Text("全部")
                        if selection == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }

            ForEach(options, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    HStack {
                        Text(option)
                        if selection == option {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selection ?? title)
                    .font(.subheadline)
                    .foregroundStyle(selection != nil ? Color.mintPrimary : .secondary)

                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(selection != nil ? Color.mintPrimary.opacity(0.1) : Color.gray.opacity(0.1))
            )
        }
    }
}
