//
//  ReviewManager.swift
//  Chihu
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    @Entry var reviewManager = ReviewManager()
}

enum ReviewCriteria {
    case launch
    case delay(seconds: TimeInterval)
}

struct ReviewManager {
    private let minLaunchCount = 7
    private let minReviewCount = 3
    private let hasRequestedAppReviewKey = "hasRequestedReview"
    private let launchCountKey = "launchCount"
    private let reviewCountKey = "reviewCount"
    private let userDefaultsAppGroup = UserDefaults(suiteName: "group.nunesdennis.chihu")
    
    func requestReviewIfNeeded(criteria: ReviewCriteria, requestReview: @escaping () -> Void) {
        guard let defaults = userDefaultsAppGroup else {
            return
        }
        
        if defaults.bool(forKey: hasRequestedAppReviewKey) {
            return
        }
        
        switch criteria {
        case .launch:
            let newLaunchCount = defaults.integer(forKey: launchCountKey) + 1
            defaults.set(newLaunchCount, forKey: launchCountKey)
            
            guard newLaunchCount >= minLaunchCount else { return }
            requestReview()
            defaults.set(true, forKey: hasRequestedAppReviewKey)
        case .delay(let seconds):
            let newReviewCount = defaults.integer(forKey: reviewCountKey) + 1
            defaults.set(newReviewCount, forKey: reviewCountKey)
            
            guard newReviewCount >= minReviewCount else { return }
            Task {
                try? await Task.sleep(for: .seconds(seconds))
                if !defaults.bool(forKey: hasRequestedAppReviewKey) {
                    defaults.set(true, forKey: hasRequestedAppReviewKey)
                }
            }
        }
    }
}
