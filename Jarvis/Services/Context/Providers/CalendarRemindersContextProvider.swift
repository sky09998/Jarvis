//
//  CalendarRemindersContextProvider.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import EventKit

final class CalendarRemindersContextProvider: ContextProvider {
    let name: String = "agenda"
    private let store = EKEventStore()

    func fetchContext(completion: @escaping ([String : Any]) -> Void) {
        store.requestFullAccessToEvents { [weak self] granted, _ in
            guard let self else { completion([:]); return }
            guard granted else { completion([:]); return }
            let now = Date()
            let end = Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
            let predicate = self.store.predicateForEvents(withStart: now, end: end, calendars: nil)
            let events = self.store.events(matching: predicate).prefix(5)
            let eventSummaries: [[String: Any]] = events.map { e in
                ["title": e.title ?? "(No Title)",
                 "start": ISO8601DateFormatter().string(from: e.startDate),
                 "location": e.location ?? ""]
            }

            self.store.requestFullAccessToReminders { granted, _ in
                var remindersSummary: [[String: Any]] = []
                if granted {
                    let predicate = self.store.predicateForIncompleteReminders(withDueDateStarting: nil, ending: end, calendars: nil)
                    self.store.fetchReminders(matching: predicate) { reminders in
                        remindersSummary = reminders?.prefix(10).map { r in
                            ["title": r.title,
                             "due": r.dueDateComponents?.date.flatMap { ISO8601DateFormatter().string(from: $0) } ?? ""]
                        } ?? []
                        completion(["events": eventSummaries, "reminders": remindersSummary])
                    }
                } else {
                    completion(["events": eventSummaries, "reminders": []])
                }
            }
        }
    }
}


