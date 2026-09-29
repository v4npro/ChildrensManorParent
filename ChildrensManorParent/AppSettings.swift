import Foundation

enum AppSettings {
    private static let startKey = "cmms.startOnCheckIn"

    static var startOnCheckIn: Bool {
        get {
            if UserDefaults.standard.object(forKey: startKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: startKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: startKey) }
    }
}
