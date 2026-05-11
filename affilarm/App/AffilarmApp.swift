import SwiftData
import SwiftUI
@preconcurrency import UserNotifications

@main
struct AffilarmApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
                    _ = await NotificationService.requestAuthorization()
                }
        }
        .modelContainer(for: [Alarm.self, Phrase.self, PhraseSet.self, VoiceProfile.self, PlayRecord.self])
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, @unchecked Sendable {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        return true
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = NotificationDelegate()

    /// Show banner when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // Also trigger the firing view
        let alarmID = extractAlarmID(from: notification.request.identifier)
        if let alarmID {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .alarmFired, object: nil, userInfo: ["alarmID": alarmID])
            }
        }
        return [.banner, .sound, .badge]
    }

    /// Handle notification tap (app was in background)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let alarmID = extractAlarmID(from: response.notification.request.identifier)
        if let alarmID {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .alarmFired, object: nil, userInfo: ["alarmID": alarmID])
            }
        }
    }

    /// Extract alarm UUID from notification identifier (format: "UUID" or "UUID-dayIndex")
    private func extractAlarmID(from identifier: String) -> UUID? {
        let uuidString = identifier.contains("-") && identifier.count > 36
            ? String(identifier.prefix(36))
            : identifier
        return UUID(uuidString: uuidString)
    }
}
