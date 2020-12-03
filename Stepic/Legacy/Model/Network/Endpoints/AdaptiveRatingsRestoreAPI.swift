import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class AdaptiveRatingsRestoreAPI: APIEndpoint {
    override var name: String { "rating-restore" }

    func restore(courseID: Int) -> Promise<(exp: Int, streak: Int)> {
        var params: Parameters = [
            "course": courseID
        ]

        if let token = AuthInfo.shared.token?.accessToken {
            params["token"] = token
        }

        return Promise { seal in
            self.manager.request(
                "\(RemoteConfig.shared.adaptiveBackendURL)/\(self.name)",
                method: .get,
                parameters: params,
                encoding: URLEncoding.default,
                headers: nil
            ).validate().responseSwiftyJSON { response in
                switch response.result {
                case .failure(let error):
                    seal.reject(error)
                case .success(let json):
                    let exp = json["exp"].intValue
                    let streak = json["streak"].intValue
                    seal.fulfill((exp: exp, streak: streak))
                }
            }
        }
    }
}
