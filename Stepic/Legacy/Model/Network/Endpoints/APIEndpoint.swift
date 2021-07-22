//
//  APIEndpoint.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import CoreData
import Foundation
import PromiseKit
import SwiftyJSON

class APIEndpoint {
    var name: String { "" }

    let manager: Alamofire.Session

    var update: UpdateRequestMaker
    var delete: DeleteRequestMaker
    var create: CreateRequestMaker
    var retrieve: RetrieveRequestMaker

    init() {
        var eventMonitors = [EventMonitor]()
        #if DEBUG
        if LaunchArguments.isNetworkDebuggingEnabled {
            eventMonitors = [AlamofireRequestsLogger()]
        }
        #endif

        self.manager = Alamofire.Session(
            configuration: StepikURLSessionConfiguration.default,
            interceptor: StepikRequestInterceptor(),
            eventMonitors: eventMonitors
        )

        self.update = UpdateRequestMaker()
        self.delete = DeleteRequestMaker()
        self.create = CreateRequestMaker()
        self.retrieve = RetrieveRequestMaker()
    }

    func cancelAllTasks() {
        manager.session.getAllTasks(completionHandler: {
            tasks in
            tasks.forEach({ $0.cancel() })
        })
    }

    //TODO: Remove this in next refactoring iterations
    func getObjectsByIds<T: JSONSerializable>(
        ids: [T.IdType],
        updating: [T],
        printOutput: Bool = false
    ) -> Promise<([T])> {
        self.retrieve.request(
            requestEndpoint: self.name,
            paramName: self.name,
            ids: ids,
            updating: updating,
            withManager: self.manager
        )
    }

    func getObjectsByIds<T: JSONSerializable>(
        requestString: String,
        printOutput: Bool = false,
        ids: [T.IdType],
        deleteObjects: [T],
        refreshMode: RefreshMode,
        success: (([T]) -> Void)?,
        failure : @escaping (_ error: NetworkError) -> Void
    ) -> Request? {
        self.getObjectsByIds(
            ids: ids,
            updating: deleteObjects
        ).done { objects in
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
