//
//  AdaptiveSubmissionsAPI.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class AdaptiveSubmissionsAPI: SubmissionsAPI {
    override var url: String {
        return StepicApplicationsInfo.adaptiveRatingURL
    }

    override var additionalParams: [String: Any] {
        return ["course": StepicApplicationsInfo.adaptiveCourseId, "user": AuthInfo.shared.userId ?? 0]
    }
}
