@preconcurrency import UserNotifications

enum NotificationService {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("[NotificationService] Authorization error: \(error)")
            return false
        }
    }

    static func scheduleAlarm(_ alarm: Alarm) {
        let center = UNUserNotificationCenter.current()

        removeAlarm(alarm)

        guard alarm.isEnabled else {
            print("[NotificationService] Alarm \(alarm.id) disabled — removed")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "affilarm"
        content.body = "アファメーションの時間です"
        content.sound = .default
        content.interruptionLevel = .timeSensitive

        let activeDays = alarm.weekdays.enumerated().filter { $0.element }.map { $0.offset }

        if activeDays.isEmpty {
            var dateComponents = DateComponents()
            dateComponents.hour = alarm.hour
            dateComponents.minute = alarm.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: alarm.id.uuidString,
                content: content,
                trigger: trigger
            )
            let h = alarm.hour
            let m = alarm.minute
            center.add(request) { error in
                if let error {
                    print("[NotificationService] Failed to schedule: \(error)")
                } else {
                    print("[NotificationService] Scheduled one-time alarm at \(h):\(m)")
                }
            }
        } else {
            // weekdays array: 0=Mon..6=Sun → Calendar weekday: Sun=1, Mon=2..Sat=7
            for dayIndex in activeDays {
                let calendarWeekday = dayIndex == 6 ? 1 : dayIndex + 2
                var dateComponents = DateComponents()
                dateComponents.hour = alarm.hour
                dateComponents.minute = alarm.minute
                dateComponents.weekday = calendarWeekday
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let requestId = "\(alarm.id.uuidString)-\(dayIndex)"
                let request = UNNotificationRequest(
                    identifier: requestId,
                    content: content,
                    trigger: trigger
                )
                let h = alarm.hour
                let m = alarm.minute
                center.add(request) { error in
                    if let error {
                        print("[NotificationService] Failed to schedule day \(dayIndex): \(error)")
                    } else {
                        print("[NotificationService] Scheduled weekday \(dayIndex) at \(h):\(m)")
                    }
                }
            }
        }
    }

    static func removeAlarm(_ alarm: Alarm) {
        let center = UNUserNotificationCenter.current()
        var ids = [alarm.id.uuidString]
        for i in 0..<7 {
            ids.append("\(alarm.id.uuidString)-\(i)")
        }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    /// Debug: print all pending notifications
    static func debugPrintPending() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("[NotificationService] Pending: \(requests.count)")
            for req in requests {
                if let trigger = req.trigger as? UNCalendarNotificationTrigger {
                    print("  - \(req.identifier): next=\(trigger.nextTriggerDate()?.description ?? "nil")")
                }
            }
        }
    }
}
