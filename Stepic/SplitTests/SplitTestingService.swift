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
    private let analyticsService: ABAnalyticsServiceProtocol
    private let storage: StringStorageServiceProtocol

    init(analyticsService: ABAnalyticsServiceProtocol, storage: StringStorageServiceProtocol) {
        self.analyticsService = analyticsService
        self.storage = storage
    }

    /// Tries to return the current split test group from the persistent store,
    /// but if current split test group doesn't saved — it will generate a new one and save it,
    /// before returning back.
    ///
    /// - Parameter splitTestType: A split test for fetch current group.
    /// - Returns: Current split test group from the storage if can, otherwise a random one.
    func fetchSplitTest<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value {
        if let value = self.getGroup(splitTestType) {
            return Value(currentGroup: value, analytics: self.analyticsService)
        }

        let randomGroup = self.randomGroup(Value.self)
        self.saveGroup(splitTestType, group: randomGroup)
        return Value(currentGroup: randomGroup, analytics: self.analyticsService)
    }

    /// Saves split test to persistent storage for future usage for the current user.
    ///
    /// - Parameters:
    ///   - splitTestType: A split test type to save group.
    ///   - group: A split test group to save to the storage.
    private func saveGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type, group: Value.GroupType) {
        self.storage.save(string: group.rawValue, for: Value.databaseKey)
    }

    /// Loads split test instance with the specific group for the current user.
    ///
    /// - Parameter splitTestType: A split test type to get group.
    /// - Returns: Split test group for the given split test type if it contains in the storage,
    ///   otherwise returns nil.
    private func getGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value.GroupType? {
        guard let stringValue = self.storage.getString(for: Value.databaseKey) else {
            return nil
        }
        return Value.GroupType(rawValue: stringValue)
    }

    /// Generates random split test group for the current split test class.
    ///
    /// - Parameter splitTestType: A split test type to generate group.
    /// - Returns: Random split test group for the given split test type.
    private func randomGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value.GroupType {
        let count = Value.GroupType.groups.count
        let random = Int.random(lower: 0, count - 1)
        return Value.GroupType.groups[random]
    }
}
