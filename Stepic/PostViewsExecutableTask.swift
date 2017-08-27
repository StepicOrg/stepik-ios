//
//  PostViewsExecutableTask.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

/*
 ExecutableTask for deleting device on the server
 */
class PostViewsExecutableTask: Executable, DictionarySerializable {

    var id: String {
        get {
            return description
        }
    }

    init(stepId: Int, assignmentId: Int?, userId: Int) {
        self.userId = userId
        self.stepId = stepId
        self.assignmentId = assignmentId
    }

    convenience required init?(dictionary dict: [String: Any]) {
        guard let taskDict = dict["task"] as? [String: Any] else {
            return nil
        }
        guard let typeString = dict["type"] as? String,
        let user = taskDict["user"] as? Int,
        let step = taskDict["step"] as? Int else {
            return nil
        }
        let assignment = taskDict["assignment"] as? Int

        if ExecutableTaskType(rawValue: typeString) != ExecutableTaskType.postViews {
            return nil
        }
        self.init(stepId: step, assignmentId: assignment, userId: user)
    }

    func serializeToDictionary() -> [String : Any] {
        let res: [String: Any] =
            [
                "type": type.rawValue,
                "task": [
                    "user": userId,
                    "step": stepId,
                    "assignment": assignmentId
                ]
        ]
        print(res)
        return res
    }

    var type: ExecutableTaskType {
        return .postViews
    }

    var userId: Int
    var stepId: Int
    var assignmentId: Int?

    var description: String {
        return "\(type.rawValue) \(userId) \(stepId) \(String(describing: assignmentId))"
    }

    func execute(success: @escaping (() -> Void), failure: @escaping ((ExecutionError) -> Void)) {
        let recoveryManager = PersistentUserTokenRecoveryManager(baseName: "Users")
        guard let token = recoveryManager.recoverStepicToken(userId: userId) else {
            return
        }
        let step = stepId
        let assignment = assignmentId
        let user = userId

        ApiDataDownloader.views.create(stepId: step, assignment: assignment, headers: APIDefaults.headers.bearer(token.accessToken), success: {
            print("user \(user) successfully posted views to step \(step) with assignment \(String(describing: assignment))")
            success()
        }, error: {
            error in
            print("error \(error) while posting views, trying to refresh token and retry")
            AuthManager.sharedManager.refreshTokenWith(token.refreshToken, success: {
                    token in
                    print("successfully refreshed token")
                    if AuthInfo.shared.userId == user {
                        AuthInfo.shared.token = token
                    }
                    recoveryManager.writeStepicToken(token, userId: user)
                    ApiDataDownloader.views.create(stepId: step, assignment: assignment, headers: APIDefaults.headers.bearer(token.accessToken), success: {
                        print("user \(user) successfully posted views to step \(step) with assignment \(String(describing: assignment)) after refreshing the token")
                        success()
                    }, error: {
                        error in
                        print("error while posting views with refreshed token")
                        switch error {
                        case .notAuthorized:
                            failure(.remove)
                            return
                        case .other(error: let e, code: _, message: let message):
                            print(message ?? "")
                            if e != nil {
                                failure(.retry)
                            } else {
                                failure(.remove)
                            }
                            return
                        }
                    })
            }, failure: {
                error in
                print("error while refreshing the token :(")
                failure(error == .other ? .retry : .remove)
            })
        })
    }
}
