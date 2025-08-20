//
//  NotificationsContextProvider.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import UserNotifications

final class NotificationsContextProvider: ContextProvider {
    let name: String = "notifications"

    func fetchContext(completion: @escaping ([String : Any]) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            let context: [String: Any] = [
                "authorizationStatus": settings.authorizationStatus.rawValue,
                "alertStyle": settings.alertStyle.rawValue,
                "soundSetting": settings.soundSetting.rawValue,
                "badgeSetting": settings.badgeSetting.rawValue
            ]
            completion(context)
        }
    }
}


