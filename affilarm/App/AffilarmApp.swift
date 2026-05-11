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

/// Separate delegate class to avoid Sendable issues with UNUserNotificationCenterDelegate
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}
