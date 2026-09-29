import Foundation

enum AppSettings {
    private static let startKey = "cmms.startOnCheckIn"
    private static let barKey = "cmms.hideAppBar"

    static var startOnCheckIn: Bool {
        get {
            if UserDefaults.standard.object(forKey: startKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: startKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: startKey) }
    }

    static var hideAppBar: Bool {
        get {
            if UserDefaults.standard.object(forKey: barKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: barKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: barKey) }
    }
}
