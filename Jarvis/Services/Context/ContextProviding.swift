//
//  ContextProviding.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation

protocol ContextProvider {
    var name: String { get }
    func fetchContext(completion: @escaping ([String: Any]) -> Void)
}

final class ContextManager {
    private let providers: [ContextProvider]

    init(providers: [ContextProvider]) {
        self.providers = providers
    }

    func snapshot(completion: @escaping ([String: Any]) -> Void) {
        var result: [String: Any] = [:]
        let group = DispatchGroup()

        for provider in providers {
            group.enter()
            provider.fetchContext { context in
                result[provider.name] = context
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(result)
        }
    }

    static func jsonString(from snapshot: [String: Any]) -> String {
        guard JSONSerialization.isValidJSONObject(snapshot),
              let data = try? JSONSerialization.data(withJSONObject: snapshot, options: [.sortedKeys]),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}


