//
//  DeviceContextProvider.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import UIKit
import Network

final class DeviceContextProvider: ContextProvider {
    let name: String = "device"

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "DeviceContextProvider.network")

    init() {
        monitor.start(queue: queue)
    }

    func fetchContext(completion: @escaping ([String : Any]) -> Void) {
        var context: [String: Any] = [:]

        context["time"] = ISO8601DateFormatter().string(from: Date())
        context["locale"] = Locale.current.identifier
        context["timeZone"] = TimeZone.current.identifier

        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        context["battery"] = [
            "level": device.batteryLevel,
            "state": device.batteryState.rawValue
        ]

        let screen = UIScreen.main
        context["screen"] = [
            "bounds": ["w": Int(screen.bounds.width), "h": Int(screen.bounds.height)],
            "scale": screen.scale
        ]

        let status = monitor.currentPath
        context["network"] = [
            "online": status.status == .satisfied,
            "expensive": status.isExpensive,
            "constrained": status.isConstrained
        ]

        completion(context)
    }
}


