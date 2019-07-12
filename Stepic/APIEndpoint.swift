//
//  APIEndpoint.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData
import PromiseKit

class APIEndpoint {

    var name: String {
        return ""
    }

    let manager: Alamofire.SessionManager

    var update: UpdateRequestMaker
    var delete: DeleteRequestMaker
    var create: CreateRequestMaker
    var retrieve: RetrieveRequestMaker

    init() {
        manager = Alamofire.SessionManager(configuration: StepikURLSessionConfiguration.default)
        let retrier = ApiRequestRetrier()
        manager.retrier = retrier
        manager.adapter = retrier

        update = UpdateRequestMaker()
        delete = DeleteRequestMaker()
        create = CreateRequestMaker()
        retrieve = RetrieveRequestMaker()
    }

    func cancelAllTasks() {
        manager.session.getAllTasks(completionHandler: {
            tasks in
            tasks.forEach({ $0.cancel() })
        })
    }

    //TODO: Remove this in next refactoring iterations
    func getObjectsByIds<T: JSONSerializable>(ids: [T.IdType], updating: [T], printOutput: Bool = false) -> Promise<([T])> {
        return retrieve.request(requestEndpoint: name, paramName: name, ids: ids, updating: updating, withManager: manager)
    }

    func getObjectsByIds<T: JSONSerializable>(requestString: String, printOutput: Bool = false, ids: [T.IdType], deleteObjects: [T], refreshMode: RefreshMode, success: (([T]) -> Void)?, failure : @escaping (_ error: NetworkError) -> Void) -> Request? {
        getObjectsByIds(ids: ids, updating: deleteObjects).done { objects in
            success?(objects)
        }.catch { error in
            guard let e = error as? NetworkError else {
                failure(NetworkError(error: error))
                return
            }
            failure(e)
        }
        return nil
    }
}
