//
//  ClothingDetailViewModel.swift
//  Clothing Mint
//
//  服装详情 ViewModel，管理详情展示、上架切换、标记售出等操作
//

import Foundation
import Supabase

/// 服装详情 ViewModel
@Observable final class ClothingDetailViewModel {
    var clothing: ClothingInventory?
    var isLoading = false
    var isUpdating = false

    // 闲鱼链接编辑
    var xianyuLinkInput = ""
    var showLinkEditor = false

    // Toast
    var showToast = false
    var toastType: ToastType = .error
    var toastMessage = ""

    private let clothingService = ClothingService()
    private let clothingId: String

    init(clothingId: String) {
        self.clothingId = clothingId
    }

    // MARK: - 加载详情

    func loadDetail() async {
        isLoading = true
        do {
            clothing = try await clothingService.getById(clothingId)
            xianyuLinkInput = clothing?.xianyuLink ?? ""
        } catch {
            showError("加载详情失败: \(error.localizedDescription)")
        }
        isLoading = false
    }

    // MARK: - 切换上架状态（通过闲鱼链接）

    func saveXianyuLink() async {
        let link = xianyuLinkInput.trimmingCharacters(in: .whitespacesAndNewlines)

        isUpdating = true
        do {
            let data: [String: AnyJSON] = [
                "xianyu_link": link.isEmpty ? .null : .string(link),
                "updated_at": .string(DateFormatters.iso8601.string(from: .now))
            ]
            try await clothingService.update(id: clothingId, data: data)
            clothing?.xianyuLink = link.isEmpty ? nil : link
            showLinkEditor = false
            showSuccess(link.isEmpty ? "已下架" : "已上架")
        } catch {
            showError("更新失败: \(error.localizedDescription)")
        }
        isUpdating = false
    }

    // MARK: - 标记已售出

    func markAsSold() async {
        isUpdating = true
        do {
            let now = DateFormatters.iso8601.string(from: .now)
            let data: [String: AnyJSON] = [
                "stock_out_date": .string(now),
                "updated_at": .string(now)
            ]
            try await clothingService.update(id: clothingId, data: data)
            clothing?.stockOutDate = now
            showSuccess("已标记售出")
        } catch {
            showError("操作失败: \(error.localizedDescription)")
        }
        isUpdating = false
    }

    // MARK: - 标记退货

    func markAsReturned() async {
        isUpdating = true
        do {
            let now = DateFormatters.iso8601.string(from: .now)
            let data: [String: AnyJSON] = [
                "is_returned": .bool(true),
                "return_time": .string(now),
                "updated_at": .string(now)
            ]
            try await clothingService.update(id: clothingId, data: data)
            clothing?.isReturned = true
            clothing?.returnTime = now
            showSuccess("已标记退货")
        } catch {
            showError("操作失败: \(error.localizedDescription)")
        }
        isUpdating = false
    }

    // MARK: - Toast

    private func showError(_ message: String) {
        toastType = .error
        toastMessage = message
        showToast = true
    }

    private func showSuccess(_ message: String) {
        toastType = .success
        toastMessage = message
        showToast = true
        HapticFeedback.success()
    }
}
