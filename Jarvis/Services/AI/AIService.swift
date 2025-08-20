//
//  AIService.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation

enum AIIntentType: String {
    case createReminder
    case createCalendarEvent
    case sendMessage
    case placeCall
    case playMusic
    case openCamera
    case showPhotos
    case getHealthSummary
    case getLocation
    case genericAnswer
    case unknown
}

struct AIIntent {
    let type: AIIntentType
    let parameters: [String: String]
    let originalUtterance: String
}

enum AIService {
    // No instances; use static API only
    static func process(utterance: String, context: [String: Any] = [:], completion: @escaping (AIIntent) -> Void) {
        let lower = utterance.lowercased()

        // Extremely naive placeholder routing. Replace with LLM + tools later.
        let intentType: AIIntentType = {
            if lower.contains("remind") || lower.contains("reminder") { return .createReminder }
            if lower.contains("meeting") || lower.contains("calendar") || lower.contains("schedule") { return .createCalendarEvent }
            if lower.contains("text") || lower.contains("message") { return .sendMessage }
            if lower.contains("call") { return .placeCall }
            if lower.contains("play") || lower.contains("music") || lower.contains("song") { return .playMusic }
            if lower.contains("camera") { return .openCamera }
            if lower.contains("photo") || lower.contains("pictures") { return .showPhotos }
            if lower.contains("health") || lower.contains("steps") || lower.contains("heart") { return .getHealthSummary }
            if lower.contains("where am i") || lower.contains("location") { return .getLocation }
            if lower.isEmpty { return .unknown }
            return .genericAnswer
        }()

        var params: [String: String] = [:]
        if let name = extractName(from: lower) { params["name"] = name }
        if let time = extractTimePhrase(from: lower) { params["time"] = time }

        let intent = AIIntent(type: intentType, parameters: params, originalUtterance: utterance)
        completion(intent)
    }

    private static func extractName(from text: String) -> String? {
        // Simple heuristic: "to <name>" after message/call
        if let range = text.range(of: " to ") {
            let after = text[range.upperBound...]
            return after.split(separator: " ").first.map(String.init)
        }
        return nil
    }

    private static func extractTimePhrase(from text: String) -> String? {
        // Very naive placeholder for demo: find "at <time>" or "tomorrow"
        if let range = text.range(of: " at ") {
            let after = text[range.upperBound...]
            let token = after.split(separator: " ").first.map(String.init)
            return token
        }
        if text.contains("tomorrow") { return "tomorrow" }
        if text.contains("today") { return "today" }
        return nil
    }
}


