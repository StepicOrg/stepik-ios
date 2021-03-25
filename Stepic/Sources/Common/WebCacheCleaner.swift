import Foundation
import WebKit

enum WebCacheCleaner {
    static func clean() {
        for cookie in HTTPCookieStorage.shared.cookies ?? [] where !StepikSession.isStepikSessionCookie(cookie) {
            HTTPCookieStorage.shared.deleteCookie(cookie)
            print("WebCacheCleaner :: Cookie \(cookie) deleted")
        }

        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                print("WebCacheCleaner :: Record \(record) deleted")
            }
        }
    }
}
