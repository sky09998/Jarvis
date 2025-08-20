//
//  HealthContextProvider.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import HealthKit

final class HealthContextProvider: ContextProvider {
    let name: String = "health"
    private let healthStore = HKHealthStore()

    func fetchContext(completion: @escaping ([String : Any]) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { completion([:]); return }
        let stepsType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let readTypes: Set = [stepsType]
        healthStore.requestAuthorization(toShare: [], read: readTypes) { [weak self] granted, _ in
            guard let self, granted else { completion([:]); return }
            let now = Date()
            let start = Calendar.current.startOfDay(for: now)
            let predicate = HKQuery.predicateForSamples(withStart: start, end: now)
            let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
                let steps = stats?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                completion(["stepsToday": Int(steps)])
            }
            self.healthStore.execute(query)
        }
    }
}


