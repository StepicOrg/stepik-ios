//
//  DeleteRequestMaker.swift
//  Stepic
//
//  Created by Ostrenkiy on 20.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import PromiseKit

final class DeleteRequestMaker {
    func request(requestEndpoint: String, deletingId: Int, withManager manager: Alamofire.SessionManager) -> Promise<Void> {
        return Promise { seal in
            checkToken().done {
                manager.request("\(StepicApplicationsInfo.apiURL)/\(requestEndpoint)/\(deletingId)", method: .delete, encoding: JSONEncoding.default).validate().responseSwiftyJSON { response in
                    switch response.result {
                    case .failure(let error):
                        seal.reject(NetworkError(error: error))
                    case .success:
                        seal.fulfill(())
                    }
                }
            }.catch {
                error in
                seal.reject(error)
            }
        }
    }
}
