//
//  AdaptiveStatsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol AdaptiveStatsView: class {

}

class AdaptiveStatsPresenter {
    weak var view: AdaptiveStatsView?
    
    var recordsCount: Int {
        return 0
    }
    
    var currentXP: Int!
    var currentLevel: Int!
    var currentWeekXP: Int!
    var bestStreak: Int!
    
    init(view: AdaptiveStatsView) {
        self.view = view
        
        loadStats()
    }
    
    fileprivate func loadStats() {
        currentXP = RatingHelper.retrieveRating()
        currentLevel = RatingHelper.getLevel(for: currentXP)
        bestStreak = 0
        currentWeekXP = 0
    }
    
}
