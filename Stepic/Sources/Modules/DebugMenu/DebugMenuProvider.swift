import FirebaseMessaging
import Foundation
import PromiseKit

protocol DebugMenuProviderProtocol: AnyObject {
    var iapCreateCoursePaymentDelay: Double? { get set }

    func fetchFCMRegistrationToken() -> Guarantee<StepikResult<String>>
}

final class DebugMenuProvider: DebugMenuProviderProtocol {
    private let iapSettingsStorageManager: IAPSettingsStorageManagerProtocol

    init(iapSettingsStorageManager: IAPSettingsStorageManagerProtocol) {
        self.iapSettingsStorageManager = iapSettingsStorageManager
    }

    var iapCreateCoursePaymentDelay: Double? {
        get {
            self.iapSettingsStorageManager.createCoursePaymentDelay
        }
        set {
            self.iapSettingsStorageManager.createCoursePaymentDelay = newValue
        }
    }

    func fetchFCMRegistrationToken() -> Guarantee<StepikResult<String>> {
        Guarantee { seal in
            Messaging.messaging().token { (tokenOrNil, errorOrNil) in
                if let error = errorOrNil {
                    seal(.failure(error))
                } else if let token = tokenOrNil {
                    seal(.success(token))
                } else {
                    seal(.failure(Error.fetchFailed))
                }
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}
