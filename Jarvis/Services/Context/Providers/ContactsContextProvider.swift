//
//  ContactsContextProvider.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import Contacts

final class ContactsContextProvider: ContextProvider {
    let name: String = "contacts"
    private let store = CNContactStore()

    func fetchContext(completion: @escaping ([String : Any]) -> Void) {
        store.requestAccess(for: .contacts) { [weak self] granted, _ in
            guard let self, granted else { completion([:]); return }
            let keys: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor,
                                           CNContactFamilyNameKey as CNKeyDescriptor]
            let request = CNContactFetchRequest(keysToFetch: keys)
            var names: [String] = []
            do {
                try self.store.enumerateContacts(with: request) { contact, _ in
                    let full = (contact.givenName + " " + contact.familyName).trimmingCharacters(in: .whitespaces)
                    if !full.isEmpty { names.append(full) }
                }
            } catch {
                completion([:])
                return
            }
            completion(["topNames": Array(names.prefix(10))])
        }
    }
}


