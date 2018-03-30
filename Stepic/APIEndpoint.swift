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

enum RetrieveError: Error {
    case connectionError, badStatus, cancelled, parsingError

    init(error: Error) {
        guard let error = error as? NSError else {
            self = .connectionError
            return
        }
        switch error.code {
        case -6003: self = .badStatus
        case -999: self = .cancelled
        default: self = .connectionError
        }
    }
}

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
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        manager = Alamofire.SessionManager(configuration: configuration)
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

    func constructIdsString<TID>(array arr: [TID]) -> String {
        var result = ""
        for element in arr {
            result += "ids[]=\(element)&"
        }
        if result != "" {
            result.remove(at: result.index(before: result.endIndex))
        }
        return result
    }

    //TODO: Remove this in next refactoring iterations
    func getObjectsByIds<T: JSONSerializable>(ids: [T.idType], updating: [T], printOutput: Bool = false) -> Promise<([T])> {
        return retrieve.request(requestEndpoint: name, paramName: name, ids: ids, updating: updating, withManager: manager)
    }

    func getObjectsByIds<T: JSONSerializable>(requestString: String, printOutput: Bool = false, ids: [T.idType], deleteObjects: [T], refreshMode: RefreshMode, success: (([T]) -> Void)?, failure : @escaping (_ error: RetrieveError) -> Void) -> Request? {
        getObjectsByIds(ids: ids, updating: deleteObjects).then {
            objects in
            success?(objects)
        }.catch {
            error in
            guard let e = error as? RetrieveError else {
                failure(RetrieveError(error: error))
                return
            }
            failure(e)
        }
        return nil
    }
}
