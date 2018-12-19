//
//  SplitTestGroupProtocol.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation
import CoreGraphics

/// Represents split test group.
///
/// By adopting to the `RawRepresentable` it possible to create the group from `RawValue`
/// or convert it back to `RawValue`.
protocol SplitTestGroupProtocol: RawRepresentable where RawValue == String {
    /// Groups that split test will contain.
    ///
    /// Primary this is using for random group generation. See `SplitTestingService.randomGroup(_:)`.
    static var groups: [Self] { get }
}
