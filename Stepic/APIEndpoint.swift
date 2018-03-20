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

    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        manager = Alamofire.SessionManager(configuration: configuration)
        let retrier = ApiRequestRetrier()
        manager.retrier = retrier
        manager.adapter = retrier
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

    func getObjectsByIds<T: JSONInitializable>(ids: [T.idType], updating: [T], headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, printOutput: Bool = false) -> Promise<([T])> {
        let name = self.name
        return Promise<([T])> {
            fulfill, reject in
            let params: Parameters = [
                "ids": ids
            ]

            manager.request("\(StepicApplicationsInfo.apiURL)/\(name)", parameters: params, encoding: URLEncoding.default).validate().responseSwiftyJSON { response in
//                print(response.request?.allHTTPHeaderFields)
                switch response.result {

                case .failure(let error):
                    reject(RetrieveError(error: error))

                case .success(let json):
                    let jsonArray: [JSON] = json[name].array ?? []
                    let resultArray: [T] = jsonArray.map {
                        objectJSON in
                        if let recoveredIndex = updating.index(where: { $0.hasEqualId(json: objectJSON) }) {
                            updating[recoveredIndex].update(json: objectJSON)
                            return updating[recoveredIndex]
                        } else {
                            return T(json: objectJSON)
                        }
                    }

                    CoreDataHelper.instance.save()
                    fulfill((resultArray))
                }

            }
        }
    }

    func getObjectsByIds<T: JSONInitializable>(requestString: String, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, printOutput: Bool = false, ids: [T.idType], deleteObjects: [T], refreshMode: RefreshMode, success: (([T]) -> Void)?, failure : @escaping (_ error: RetrieveError) -> Void) -> Request? {

        let params: Parameters = [:]

        let idString = constructIdsString(array: ids)
        if idString == "" {
            success?([])
            return nil
        }

        return manager.request("\(StepicApplicationsInfo.apiURL)/\(requestString)?\(idString)", parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response

            if printOutput {
                print(json)
            }

            if let e = error as NSError? {
                print("RETRIEVE \(requestString)?\(ids): error \(e.domain) \(e.code): \(e.localizedDescription)")
                if e.code == -999 {
                    failure(.cancelled)
                    return
                } else {
                    failure(.connectionError)
                    return
                }
            }

            if response?.statusCode != 200 {
                print("RETRIEVE \(requestString)?\(ids)): bad response status code \(String(describing: response?.statusCode))")
                failure(.badStatus)
                return
            }

            var newObjects: [T] = []

            switch refreshMode {

            case .delete:

                for object in deleteObjects {
                    CoreDataHelper.instance.deleteFromStore(object as! NSManagedObject, save: false)
                }

                for objectJSON in json[requestString].arrayValue {
                    newObjects += [T(json: objectJSON)]
                }

            case .update:

                for objectJSON in json[requestString].arrayValue {
                    let existing = deleteObjects.filter({obj in obj.hasEqualId(json: objectJSON)})

                    switch existing.count {
                    case 0:
                        newObjects += [T(json: objectJSON)]
                    case 1:
                        let obj = existing[0]
                        obj.update(json: objectJSON)
                        newObjects += [obj]
                    default:
                        //TODO: Fix this in the next releases! We have some problems with deleting entities from CoreData
                        let obj = existing[0]
                        obj.update(json: objectJSON)
                        newObjects += [obj]
                        print("More than 1 object with the same id!")
                    }
                }
            }

            CoreDataHelper.instance.save()
            success?(newObjects)
        })
    }
}
