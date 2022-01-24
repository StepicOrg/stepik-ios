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

    var timeoutIntervalForRequest: TimeInterval {
        get {
            self.manager.sessionConfiguration.timeoutIntervalForRequest
        }
        set {
            self.manager.sessionConfiguration.timeoutIntervalForRequest = newValue
        }
    }

    init(timeoutIntervalForRequest: TimeInterval = APIDefaults.Configuration.defaultTimeoutIntervalForRequest) {
        var eventMonitors = [EventMonitor]()
        #if DEBUG
        if LaunchArguments.isNetworkDebuggingEnabled {
            eventMonitors = [AlamofireRequestsLogger()]
        }
        #endif

        let configuration = StepikURLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutIntervalForRequest

        self.manager = Alamofire.Session(
            configuration: configuration,
            interceptor: StepikRequestInterceptor(),
            eventMonitors: eventMonitors
        )

        self.update = UpdateRequestMaker()
        self.delete = DeleteRequestMaker()
        self.create = CreateRequestMaker()
        self.retrieve = RetrieveRequestMaker()
    }

    func cancelAllTasks() {
        self.manager.session.getAllTasks { tasks in
            tasks.forEach { $0.cancel() }
        }
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
        failure: @escaping (_ error: NetworkError) -> Void
    ) -> Request? {
        self.getObjectsByIds(
            ids: ids,
            updating: deleteObjects
        ).done { objects in
            success?(objects)
        }.catch { error in
            guard let networkError = error as? NetworkError else {
                return failure(NetworkError(error: error))
            }
            failure(networkError)
        }
        return nil
    }
}
