//
//  VotesAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire 
import SwiftyJSON

class VotesAPI {

    func create(vote: Vote, success: (Vote->Void), error: (String->Void)) {
        success(vote)
    }
}