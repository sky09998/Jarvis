//
//  JarvisShortcuts.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import AppIntents
import Foundation
import EventKit
import Contacts
import UIKit
import MediaPlayer

// MARK: - Intents

struct OpenCameraIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Camera"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // Implementation will be handled by the app when opened
        return .result(dialog: IntentDialog("Opening Camera in Jarvis…"))
    }
}

struct ShowPhotosIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Photos"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // Implementation will be handled by the app when opened
        return .result(dialog: IntentDialog("Showing Photos in Jarvis…"))
    }
}

struct PlayMusicIntent: AppIntent {
    static var title: LocalizedStringResource = "Play Music"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        DispatchQueue.main.async {
            // Open the default music app and start playing music
            let musicPlayer = MPMusicPlayerController.systemMusicPlayer
            musicPlayer.play()
        }
        return .result(dialog: IntentDialog("Playing music…"))
    }
}

struct CreateReminderIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Reminder"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Title")
    var titleText: String

    func perform() async throws -> some IntentResult {
        let success = await createReminder(title: titleText, timeHint: nil)
        return .result(dialog: IntentDialog(success ? "Reminder created: \(titleText)" : "I couldn't create the reminder."))
    }
}

struct CreateEventIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Calendar Event"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Title")
    var titleText: String

    func perform() async throws -> some IntentResult {
        let success = await createCalendarEvent(title: titleText, timeHint: nil)
        return .result(dialog: IntentDialog(success ? "Event scheduled: \(titleText)" : "I couldn't schedule the event."))
    }
}

struct GetHealthSummaryIntent: AppIntent {
    static var title: LocalizedStringResource = "Health Summary"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // This would need to be implemented with HealthKit integration
        return .result(dialog: IntentDialog("Fetching your health summary…"))
    }
}

struct GetLocationIntent: AppIntent {
    static var title: LocalizedStringResource = "Where am I"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        // This would need to be implemented with CoreLocation integration
        return .result(dialog: IntentDialog("Checking your current location…"))
    }
}

// MARK: - Helper Functions

private func createReminder(title: String, timeHint: String?) async -> Bool {
    return await withCheckedContinuation { continuation in
        let store = EKEventStore()
        store.requestFullAccessToReminders { granted, _ in
            guard granted else { continuation.resume(returning: false); return }
            let reminder = EKReminder(eventStore: store)
            reminder.title = title
            reminder.calendar = store.defaultCalendarForNewReminders()

            if let date = parseTimeHint(timeHint) {
                let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                reminder.dueDateComponents = comps
            }

            do {
                try store.save(reminder, commit: true)
                continuation.resume(returning: true)
            } catch {
                continuation.resume(returning: false)
            }
        }
    }
}

private func createCalendarEvent(title: String, timeHint: String?) async -> Bool {
    return await withCheckedContinuation { continuation in
        let store = EKEventStore()
        store.requestFullAccessToEvents { granted, _ in
            guard granted else { continuation.resume(returning: false); return }
            let event = EKEvent(eventStore: store)
            event.calendar = store.defaultCalendarForNewEvents
            event.title = title
            let start = parseTimeHint(timeHint) ?? Date().addingTimeInterval(3600)
            event.startDate = start
            event.endDate = start.addingTimeInterval(3600)
            do {
                try store.save(event, span: .thisEvent, commit: true)
                continuation.resume(returning: true)
            } catch {
                continuation.resume(returning: false)
            }
        }
    }
}

private func parseTimeHint(_ hint: String?) -> Date? {
    guard let hint = hint?.lowercased() else { return nil }
    let now = Date()
    if hint == "tomorrow" {
        return Calendar.current.date(byAdding: .day, value: 1, to: now)
    }
    if hint == "today" {
        return now
    }
    // Try parsing simple HH:mm
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "HH:mm"
    if let t = formatter.date(from: hint) {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: now)
        return Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: t), minute: Calendar.current.component(.minute, from: t), second: 0, of: Calendar.current.date(from: comps) ?? now)
    }
    return nil
}

// MARK: - Intent Processing

extension JarvisShortcuts {
    private static func createReminder(title: String, timeHint: String?) async -> Bool {
        return await withCheckedContinuation { continuation in
            let store = EKEventStore()
            store.requestFullAccessToReminders { granted, _ in
                guard granted else { continuation.resume(returning: false); return }
                let reminder = EKReminder(eventStore: store)
                reminder.title = title
                reminder.calendar = store.defaultCalendarForNewReminders()

                if let date = parseTimeHint(timeHint) {
                    let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    reminder.dueDateComponents = comps
                }

                do {
                    try store.save(reminder, commit: true)
                    continuation.resume(returning: true)
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    private static func createCalendarEvent(title: String, timeHint: String?) async -> Bool {
        return await withCheckedContinuation { continuation in
            let store = EKEventStore()
            store.requestFullAccessToEvents { granted, _ in
                guard granted else { continuation.resume(returning: false); return }
                let event = EKEvent(eventStore: store)
                event.calendar = store.defaultCalendarForNewEvents
                event.title = title
                let start = parseTimeHint(timeHint) ?? Date().addingTimeInterval(3600)
                event.startDate = start
                event.endDate = start.addingTimeInterval(3600)
                do {
                    try store.save(event, span: .thisEvent, commit: true)
                    continuation.resume(returning: true)
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }

    private static func resolvePhoneNumber(forName name: String?, completion: @escaping (String?) -> Void) {
        guard let name, !name.isEmpty else { completion(nil); return }
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            guard granted else { completion(nil); return }
            let predicate = CNContact.predicateForContacts(matchingName: name)
            let keys: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor,
                                           CNContactFamilyNameKey as CNKeyDescriptor,
                                           CNContactPhoneNumbersKey as CNKeyDescriptor]
            var number: String?
            do {
                let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keys)
                if let contact = contacts.first, let phone = contact.phoneNumbers.first?.value.stringValue {
                    number = phone.filter { $0.isNumber || $0 == "+" }
                }
            } catch {
                number = nil
            }
            completion(number)
        }
    }

    private static func parseTimeHint(_ hint: String?) -> Date? {
        guard let hint = hint?.lowercased() else { return nil }
        let now = Date()
        if hint == "tomorrow" {
            return Calendar.current.date(byAdding: .day, value: 1, to: now)
        }
        if hint == "today" {
            return now
        }
        // Try parsing simple HH:mm
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        if let t = formatter.date(from: hint) {
            let comps = Calendar.current.dateComponents([.year, .month, .day], from: now)
            return Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: t), minute: Calendar.current.component(.minute, from: t), second: 0, of: Calendar.current.date(from: comps) ?? now)
        }
        return nil
    }
    static func processAIIntent(_ intent: AIIntent, manager: VoiceManager) {
        switch intent.type {
        case .createReminder:
            Task {
                let success = await createReminder(title: intent.originalUtterance, timeHint: intent.parameters["time"])
                await MainActor.run {
                    manager.speak(success ? "Reminder created." : "I couldn't create the reminder.")
                }
            }
        case .createCalendarEvent:
            Task {
                let success = await createCalendarEvent(title: intent.originalUtterance, timeHint: intent.parameters["time"])
                await MainActor.run {
                    manager.speak(success ? "Event scheduled." : "I couldn't schedule the event.")
                }
            }
        case .sendMessage:
            resolvePhoneNumber(forName: intent.parameters["name"]) { number in
                guard let number, let url = URL(string: "sms:\(number)") else {
                    Task { @MainActor in
                        manager.speak("I couldn't find a number to message.")
                    }
                    return
                }
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                    Task { @MainActor in
                        manager.speak("Opening Messages.")
                    }
                }
            }
        case .placeCall:
            resolvePhoneNumber(forName: intent.parameters["name"]) { number in
                guard let number, let url = URL(string: "tel:\(number)") else {
                    Task { @MainActor in
                        manager.speak("I couldn't find a number to call.")
                    }
                    return
                }
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                    Task { @MainActor in
                        manager.speak("Calling.")
                    }
                }
            }
        case .playMusic:
            DispatchQueue.main.async {
                let musicPlayer = MPMusicPlayerController.systemMusicPlayer
                musicPlayer.play()
                Task { @MainActor in
                    manager.speak("Opening Music.")
                }
            }
        case .openCamera:
            Task { @MainActor in
                manager.requestPresentation(.camera)
                manager.speak("Opening the camera.")
            }
        case .showPhotos:
            Task { @MainActor in
                manager.requestPresentation(.photoPicker)
                manager.speak("Showing your photos.")
            }
        case .getHealthSummary:
            let provider = HealthContextProvider()
            provider.fetchContext { context in
                let steps = context["stepsToday"] as? Int ?? 0
                Task { @MainActor in
                    manager.speak("You've taken \(steps) steps today.")
                }
            }
        case .getLocation:
            let provider = LocationContextProvider()
            provider.fetchContext { context in
                if let city = context["city"] as? String, let region = context["region"] as? String {
                    Task { @MainActor in
                        manager.speak("You're in \(city), \(region).")
                    }
                } else {
                    Task { @MainActor in
                        manager.speak("I found your approximate location.")
                    }
                }
            }
        case .genericAnswer, .unknown:
            Task { @MainActor in
                manager.speak(manager.summarize(intent: intent))
            }
        }
    }
}

// MARK: - App Shortcuts

struct JarvisShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .blue

    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: OpenCameraIntent(), phrases: [
            "Open camera with \(.applicationName)",
            "Launch camera in \(.applicationName)"
        ], shortTitle: "Open Camera", systemImageName: "camera.fill")

        AppShortcut(intent: ShowPhotosIntent(), phrases: [
            "Show photos with \(.applicationName)"
        ], shortTitle: "Show Photos", systemImageName: "photo.on.rectangle")

        AppShortcut(intent: PlayMusicIntent(), phrases: [
            "Play music with \(.applicationName)"
        ], shortTitle: "Play Music", systemImageName: "music.note")

        AppShortcut(intent: CreateReminderIntent(), phrases: [
            "Remember to \(.applicationName)"
        ], shortTitle: "Create Reminder", systemImageName: "checklist")

        AppShortcut(intent: CreateEventIntent(), phrases: [
            "Schedule with \(.applicationName)"
        ], shortTitle: "Create Event", systemImageName: "calendar")

        AppShortcut(intent: GetHealthSummaryIntent(), phrases: [
            "Health summary with \(.applicationName)"
        ], shortTitle: "Health Summary", systemImageName: "heart.fill")

        AppShortcut(intent: GetLocationIntent(), phrases: [
            "Where am I with \(.applicationName)"
        ], shortTitle: "Where am I", systemImageName: "location.fill")
    }
}


