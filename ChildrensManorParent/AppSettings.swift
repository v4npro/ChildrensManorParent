import Foundation

enum AppSettings {
    private static let startKey = "cmms.startOnCheckIn"
    private static let saveLoginKey = "cmms.saveLogin"
    private static let lockDelayKey = "cmms.lockDelaySeconds"

    static var startOnCheckIn: Bool {
        get {
            if UserDefaults.standard.object(forKey: startKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: startKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: startKey) }
    }

    /// Save the school passcode in the Keychain for Face ID sign-in.
    static var saveLogin: Bool {
        get {
            if UserDefaults.standard.object(forKey: saveLoginKey) == nil { return true }
            return UserDefaults.standard.bool(forKey: saveLoginKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: saveLoginKey) }
    }

    /// Seconds the app may stay in the background before Face ID is needed
    /// again. 0 locks as soon as the app leaves the screen.
    static var lockDelaySeconds: Int {
        get { UserDefaults.standard.integer(forKey: lockDelayKey) }
        set { UserDefaults.standard.set(newValue, forKey: lockDelayKey) }
    }
}
