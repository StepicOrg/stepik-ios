//
//  ProfileViewController+StreakNotificationsControlView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.05.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

enum ProfileMenuBlock: RawRepresentable, Equatable {
    typealias RawValue = String

    case infoHeader
    case notificationsSwitch(isOn: Bool)
    case notificationsTimeSelection
    case description
    case pinsMap

    init?(rawValue: RawValue) {
        fatalError("init with raw value has not been implemented")
    }

    var rawValue: RawValue {
        switch self {
        case .infoHeader:
            return "infoHeader"
        case .notificationsSwitch(_):
            return "notificationsSwitch"
        case .notificationsTimeSelection:
            return "notificationsTimeSelection"
        case .description:
            return "description"
        case .pinsMap:
            return "pinsMap"
        }
    }

    static func ==(lhs: ProfileMenuBlock, rhs: ProfileMenuBlock) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
