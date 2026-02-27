//
//  BLEManager.swift
//  Clothing Mint
//
//  蓝牙低功耗（BLE）设备管理器，负责扫描、连接、数据传输
//

import Foundation
import CoreBluetooth

/// 打印机设备模型
struct PrinterDevice: Identifiable, Hashable {
    let id: UUID
    let name: String
    let peripheral: CBPeripheral

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: PrinterDevice, rhs: PrinterDevice) -> Bool {
        lhs.id == rhs.id
    }
}

/// BLE 连接状态
enum BLEConnectionState {
    case disconnected
    case scanning
    case connecting
    case connected
    case error(String)
}

/// BLE 管理器
@Observable final class BLEManager: NSObject {
    var discoveredDevices: [PrinterDevice] = []
    var connectionState: BLEConnectionState = .disconnected
    var connectedDevice: PrinterDevice?
    var bluetoothEnabled = false

    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?

    /// 数据发送完成回调
    private var sendCompletion: ((Bool) -> Void)?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    // MARK: - 扫描

    func startScan() {
        guard let central = centralManager, central.state == .poweredOn else {
            connectionState = .error("蓝牙未开启")
            return
        }

        discoveredDevices.removeAll()
        connectionState = .scanning
        central.scanForPeripherals(withServices: nil, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])

        // 10 秒后自动停止扫描
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.stopScan()
        }
    }

    func stopScan() {
        centralManager?.stopScan()
        if case .scanning = connectionState {
            connectionState = .disconnected
        }
    }

    // MARK: - 连接/断开

    func connect(to device: PrinterDevice) {
        stopScan()
        connectionState = .connecting
        centralManager?.connect(device.peripheral, options: nil)
    }

    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
        resetConnection()
    }

    // MARK: - 发送数据

    /// 发送数据到已连接设备（20 字节分块）
    func sendData(_ data: Data, completion: @escaping (Bool) -> Void) {
        guard let peripheral = connectedPeripheral,
              let characteristic = writeCharacteristic else {
            completion(false)
            return
        }

        let chunkSize = 20
        var offset = 0

        while offset < data.count {
            let end = min(offset + chunkSize, data.count)
            let chunk = data.subdata(in: offset..<end)
            peripheral.writeValue(chunk, for: characteristic, type: .withResponse)
            offset = end
        }

        // 延迟回调，等待蓝牙传输完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(true)
        }
    }

    // MARK: - 私有方法

    private func resetConnection() {
        connectedPeripheral = nil
        connectedDevice = nil
        writeCharacteristic = nil
        connectionState = .disconnected
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEManager: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            bluetoothEnabled = central.state == .poweredOn
            if central.state != .poweredOn {
                connectionState = .error("蓝牙不可用")
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                     didDiscover peripheral: CBPeripheral,
                                     advertisementData: [String: Any],
                                     rssi RSSI: NSNumber) {
        Task { @MainActor in
            let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
            guard let deviceName = name, !deviceName.isEmpty else { return }

            let device = PrinterDevice(id: peripheral.identifier, name: deviceName, peripheral: peripheral)

            if !discoveredDevices.contains(where: { $0.id == device.id }) {
                discoveredDevices.append(device)
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                     didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            connectedPeripheral = peripheral
            connectedDevice = discoveredDevices.first(where: { $0.peripheral == peripheral })
            connectionState = .connected
            peripheral.delegate = self
            peripheral.discoverServices(nil)
            AppLogger.info("蓝牙已连接: \(peripheral.name ?? "未知")")
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                     didFailToConnect peripheral: CBPeripheral,
                                     error: Error?) {
        Task { @MainActor in
            connectionState = .error("连接失败: \(error?.localizedDescription ?? "未知错误")")
            AppLogger.error("蓝牙连接失败: \(error?.localizedDescription ?? "")")
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                     didDisconnectPeripheral peripheral: CBPeripheral,
                                     error: Error?) {
        Task { @MainActor in
            resetConnection()
            AppLogger.info("蓝牙已断开")
        }
    }
}

// MARK: - CBPeripheralDelegate

extension BLEManager: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                 didDiscoverServices error: Error?) {
        Task { @MainActor in
            guard let services = peripheral.services else { return }
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                 didDiscoverCharacteristicsFor service: CBService,
                                 error: Error?) {
        Task { @MainActor in
            guard let characteristics = service.characteristics else { return }
            for characteristic in characteristics {
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                    writeCharacteristic = characteristic
                    AppLogger.info("发现写入特征: \(characteristic.uuid)")
                    return
                }
            }
        }
    }
}
