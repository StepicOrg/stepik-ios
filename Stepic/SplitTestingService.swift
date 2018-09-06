//
//  SplitTestingService.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation
import UIKit

protocol SplitTestingServiceProtocol {
    func fetchSplitTest<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value
}

class SplitTestingService: SplitTestingServiceProtocol {
    private let analyticsService: AnalyticsUserPropertiesServiceProtocol
    private let storage: StringStorageServiceProtocol

    init(analyticsService: AnalyticsUserPropertiesServiceProtocol, storage: StringStorageServiceProtocol) {
        self.analyticsService = analyticsService
        self.storage = storage
    }

    func fetchSplitTest<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value {
        if let value = self.getGroup(splitTestType) {
            return Value(currentGroup: value, analytics: self.analyticsService)
        }

        let randomGroup = self.randomGroup(Value.self)
        self.saveGroup(splitTestType, group: randomGroup)
        return Value(currentGroup: randomGroup, analytics: self.analyticsService)
    }

    private func saveGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type, group: Value.GroupType) {
        self.storage.save(string: group.rawValue, for: Value.dataBaseKey)
    }

    private func getGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value.GroupType? {
        guard let stringValue = self.storage.getString(for: Value.dataBaseKey) else {
            return nil
        }
        return Value.GroupType(rawValue: stringValue)
    }

    private func randomGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value.GroupType {
        let count = Value.GroupType.groups.count
        let random = Int.random(lower: 0, count - 1)
        return Value.GroupType.groups[random]
    }
}
