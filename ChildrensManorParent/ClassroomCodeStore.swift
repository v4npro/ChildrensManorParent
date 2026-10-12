import Foundation

enum ClassroomCodeStore {
    private static let fallbackKey = "cmms.classroomCode"

    /// Each child keeps their own code, so a sibling's code never shows up
    /// under the wrong name. The shared key is only used when the page
    /// does not show a student name.
    static func get(student: String?) -> String {
        UserDefaults.standard.string(forKey: key(for: student)) ?? ""
    }

    static func set(_ value: String, student: String?) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmed, forKey: key(for: student))
    }

    private static func key(for student: String?) -> String {
        let slug = (student ?? "")
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        if slug.isEmpty { return fallbackKey }
        return fallbackKey + "." + slug
    }
}
