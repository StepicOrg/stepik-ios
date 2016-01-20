//
//  StringDatasetExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

extension String : Dataset {
    public init(json: JSON) {
        self = json.stringValue
    }
}
