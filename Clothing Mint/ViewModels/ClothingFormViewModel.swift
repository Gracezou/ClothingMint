//
//  ClothingFormViewModel.swift
//  Clothing Mint
//
//  服装入库表单 ViewModel，管理表单状态、验证、上传和保存
//

import SwiftUI

/// 服装入库表单 ViewModel
@Observable final class ClothingFormViewModel {

    // MARK: - 表单字段

    var code: String = ""
    var selectedType: String = ""
    var selectedSize: String = ""
    var selectedColor: String = ""
    var selectedLocation: String = ""
    var price: String = ""
    var description: String = ""
    var stockInDate: Date = .now
    var selectedImage: UIImage?

    // MARK: - 下拉选项

    var typeOptions: [String] = []
    var sizeOptions: [String] = []
    var colorOptions: [String] = []
    var locationOptions: [String] = []

    // MARK: - 上传状态

    var uploadProgress: Double = 0
    var isUploading = false
    var uploadedPhotoKey: String?

    // MARK: - 保存状态

    var isSaving = false
    var saveSuccess = false
    var savedBarcode: String?

    // MARK: - Toast

    var showToast = false
    var toastType: ToastType = .error
    var toastMessage = ""

    // MARK: - 加载状态

    var isLoadingOptions = false
    var loadOptionsFailed = false

    // MARK: - 依赖

    private let clothingService = ClothingService()
    private let dictService = DictService()
    private let uploadService = QiniuUploadService()

    // MARK: - 初始化

    init() {
        code = .generateBarcode()
    }

    // MARK: - 加载下拉选项

    func loadOptions() async {
        isLoadingOptions = true
        loadOptionsFailed = false
        do {
            let dict = try await dictService.getBatchCategories(["clothing_type", "size", "color", "location"])
            typeOptions = dict["clothing_type"]?.map(\.name).sorted() ?? []
            sizeOptions = dict["size"]?.map(\.name) ?? []
            colorOptions = dict["color"]?.map(\.name).sorted() ?? []
            locationOptions = dict["location"]?.map(\.name).sorted() ?? []
            AppLogger.info("加载选项成功: type=\(typeOptions.count), size=\(sizeOptions.count), color=\(colorOptions.count), location=\(locationOptions.count)")
        } catch {
            loadOptionsFailed = true
            showError("加载选项失败: \(error.localizedDescription)")
            AppLogger.error("加载选项失败: \(error)")
        }
        isLoadingOptions = false
    }

    // MARK: - 上传图片

    func uploadImage() async {
        guard let image = selectedImage else { return }

        isUploading = true
        uploadProgress = 0

        do {
            let url = try await uploadService.upload(image: image) { [weak self] progress in
                Task { @MainActor in
                    self?.uploadProgress = progress
                }
            }
            uploadedPhotoKey = url
            uploadProgress = 1.0
            showSuccess("图片上传成功")
        } catch {
            showError("上传失败: \(error.localizedDescription)")
            uploadProgress = 0
        }
        isUploading = false
    }

    // MARK: - 保存记录

    func save(userId: String?) async {
        guard validate() else { return }

        isSaving = true

        // 如果有图片但未上传，先尝试上传（失败不阻塞保存）
        if selectedImage != nil && uploadedPhotoKey == nil {
            await uploadImage()
        }

        let now = DateFormatters.iso8601.string(from: .now)
        let stockIn = DateFormatters.displayDate.string(from: stockInDate) + "T00:00:00+08:00"

        let clothing = ClothingInventory(
            id: UUID().uuidString,
            code: code,
            merchantId: nil,
            size: selectedSize,
            color: selectedColor,
            type: selectedType,
            location: selectedLocation,
            photoUrl: uploadedPhotoKey,
            price: Double(price) ?? 0,
            description: description.isEmpty ? nil : description,
            stockInDate: stockIn,
            stockOutDate: nil,
            xianyuLink: nil,
            isReturned: false,
            returnTime: nil,
            createdAt: now,
            updatedAt: now,
            userId: userId
        )

        do {
            try await clothingService.create(clothing)
            savedBarcode = code
            saveSuccess = true
            showSuccess("入库成功")
        } catch {
            showError("保存失败: \(error.localizedDescription)")
        }
        isSaving = false
    }

    // MARK: - 重置表单（新建下一件）

    func resetForm() {
        code = .generateBarcode()
        selectedType = ""
        selectedSize = ""
        selectedColor = ""
        // 保留位置，方便连续入库
        price = ""
        description = ""
        stockInDate = .now
        selectedImage = nil
        uploadProgress = 0
        uploadedPhotoKey = nil
        saveSuccess = false
        savedBarcode = nil
    }

    // MARK: - 重新生成条码

    func regenerateBarcode() {
        code = .generateBarcode()
        HapticFeedback.light()
    }

    // MARK: - 验证

    private func validate() -> Bool {
        if code.isEmpty {
            showError("条码不能为空")
            return false
        }
        if selectedType.isEmpty {
            showError("请选择类型")
            return false
        }
        if selectedSize.isEmpty {
            showError("请选择尺码")
            return false
        }
        if selectedColor.isEmpty {
            showError("请选择颜色")
            return false
        }
        if selectedLocation.isEmpty {
            showError("请选择存放位置")
            return false
        }
        guard let priceValue = Double(price), Validators.isValidPrice(priceValue) else {
            showError("请输入有效价格")
            return false
        }
        return true
    }

    // MARK: - Toast

    private func showError(_ message: String) {
        toastType = .error
        toastMessage = message
        showToast = true
        HapticFeedback.error()
    }

    private func showSuccess(_ message: String) {
        toastType = .success
        toastMessage = message
        showToast = true
        HapticFeedback.success()
    }
}
