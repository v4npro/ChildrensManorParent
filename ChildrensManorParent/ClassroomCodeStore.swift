import Foundation

enum ClassroomCodeStore {
    private static let fallbackKey = "cmms.classroomCode"

    static func get(student: String?) -> String {
        let specific = UserDefaults.standard.string(forKey: key(for: student)) ?? ""
        if !specific.isEmpty { return specific }
        return UserDefaults.standard.string(forKey: fallbackKey) ?? ""
    }

    static func set(_ value: String, student: String?) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmed, forKey: key(for: student))
        UserDefaults.standard.set(trimmed, forKey: fallbackKey)
    }

    private static func key(for student: String?) -> String {
        let slug = (student ?? "")
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        if slug.isEmpty { return fallbackKey }
        return fallbackKey + "." + slug
    }
}
