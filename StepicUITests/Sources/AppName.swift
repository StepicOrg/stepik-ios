import Foundation

enum AppName {
#if PRODUCTION
    static let name = "Stepik"
#elseif DEVELOP
    static let name = "Stepik Develop"
#elseif RELEASE
    static let name = "Stepik Release"
#endif
}
