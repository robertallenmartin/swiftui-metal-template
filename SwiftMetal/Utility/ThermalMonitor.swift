/*
 
 Object to monitor thermal state changes. Pauses MTK view if state is elevated.
 
 */

import SwiftUI

@MainActor
final class ThermalMonitor: ObservableObject {
    
    static let shared = ThermalMonitor()

    @Published private(set) var thermalState: ProcessInfo.ThermalState = ProcessInfo.processInfo.thermalState
    
    // Public computed property that returns a color based on the current thermal state.
    public var currentColor: Color {
        switch thermalState {
        case .nominal:
            return Color.green
        case .fair:
            return Color.yellow
        case .serious:
            return Color.orange
        case .critical:
            return Color.red
        @unknown default:
            return Color.gray
        }
    }
    
    private init() {
        listenToThermalChanges()
    }

    private func listenToThermalChanges() {
        Task {
            let notifications = NotificationCenter.default.notifications(named: ProcessInfo.thermalStateDidChangeNotification)

            for await _ in notifications {
                thermalState = ProcessInfo.processInfo.thermalState
                print("Thermal State Changed: \(thermalState)")
            }
        }
    }
}
