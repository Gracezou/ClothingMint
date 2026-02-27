//
//  PrinterViewModel.swift
//  Clothing Mint
//
//  打印机扫描/连接/打印 ViewModel
//

import Foundation

/// 打印机 ViewModel
@Observable final class PrinterViewModel {
    let printService = BluetoothPrintService()

    var isPrinting = false
    var printSuccess: Bool?

    // Toast
    var showToast = false
    var toastType: ToastType = .error
    var toastMessage = ""

    var bleManager: BLEManager { printService.bleManager }

    // MARK: - 扫描

    func startScan() {
        printService.bleManager.startScan()
    }

    func stopScan() {
        printService.bleManager.stopScan()
    }

    // MARK: - 连接

    func connect(to device: PrinterDevice) {
        printService.bleManager.connect(to: device)
    }

    func disconnect() {
        printService.bleManager.disconnect()
    }

    // MARK: - 打印

    func printLabel(clothing: ClothingInventory) async {
        isPrinting = true
        printSuccess = nil

        let success = await printService.printLabel(
            code: clothing.code,
            type: clothing.type,
            size: clothing.size,
            color: clothing.color,
            price: String(format: "%.0f", clothing.price)
        )

        printSuccess = success
        isPrinting = false

        if success {
            toastType = .success
            toastMessage = "打印成功"
            HapticFeedback.success()
        } else {
            toastType = .error
            toastMessage = "打印失败，请检查打印机连接"
            HapticFeedback.error()
        }
        showToast = true
    }
}
