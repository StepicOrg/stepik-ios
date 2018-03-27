//
//  RetrieveRequestMaker.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit
import SwiftyJSON

class RetrieveRequestMaker {
    func request<T: JSONSerializable>(requestEndpoint: String, id: T.idType, updatingObject: T? = nil, withManager manager: Alamofire.SessionManager) -> Promise<T> {
        return Promise { fulfill, reject in
            checkToken().then {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)/\(id)", method: .get, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        reject(error)
                    case .success(let json):
                        if updatingObject == nil {
                            updatingObject?.update(json: json[requestEndpoint].arrayValue[0])
                        } else {
                            fulfill(updatingObject)
                        }
                    }
                }
            }.catch {
                error in
                reject(error)
            }
        }
    }

}
