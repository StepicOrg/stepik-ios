import Foundation

struct StepikApplicationsInfo {
    // Structure
    typealias Root = ApplicationInfo.Path

    // Section: AuthInfo
    typealias AuthInfo = (clientId: String, clientSecret: String, redirectUri: String, credentials: String)

    #if PRODUCTION
    private static let stepikAuthInfo = ApplicationInfo(plist: "Auth-Production")
    private static let stepikConfigInfo = ApplicationInfo(plist: "Config-Production")
    #elseif DEVELOP
    private static let stepikAuthInfo = ApplicationInfo(plist: "Auth-Develop")
    private static let stepikConfigInfo = ApplicationInfo(plist: "Config-Develop")
    #elseif RELEASE
    private static let stepikAuthInfo = ApplicationInfo(plist: "Auth-Release")
    private static let stepikConfigInfo = ApplicationInfo(plist: "Config-Release")
    #endif

    private static func initAuthInfo(idPath: String, secretPath: String, redirectPath: String) -> AuthInfo {
        let id = Self.stepikAuthInfo?.get(for: idPath) as? String ?? ""
        let secret = Self.stepikAuthInfo?.get(for: secretPath) as? String ?? ""
        let redirect = Self.stepikAuthInfo?.get(for: redirectPath) as? String ?? ""
        let credentials = "\(id):\(secret)".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
        return (clientId: id, clientSecret: secret, redirectUri: redirect, credentials: credentials)
    }

    static let social: AuthInfo? = !(Self.stepikAuthInfo?.has(path: Root.AuthType.social) ?? false)
        ? nil
        : StepikApplicationsInfo.initAuthInfo(
            idPath: Root.AuthType.Social.id,
            secretPath: Root.AuthType.Social.secret,
            redirectPath: Root.AuthType.Social.redirect
          )

    static let password: AuthInfo? = !(Self.stepikAuthInfo?.has(path: Root.AuthType.password) ?? false)
        ? nil
        : StepikApplicationsInfo.initAuthInfo(
            idPath: Root.AuthType.Password.id,
            secretPath: Root.AuthType.Password.secret,
            redirectPath: Root.AuthType.Password.redirect
          )

    // Section: URL
    static let appId = Self.stepikConfigInfo?.get(for: Root.URL.appId) as? String ?? ""
    static let urlScheme = Self.stepikConfigInfo?.get(for: Root.URL.scheme) as? String ?? ""
    static var apiURL = Self.stepikConfigInfo?.get(for: Root.URL.api) as? String ?? ""
    static let oauthURL = Self.stepikConfigInfo?.get(for: Root.URL.oauth) as? String ?? ""
    static let stepikURL = Self.stepikConfigInfo?.get(for: Root.URL.stepik) as? String ?? ""
    static let versionInfoURL = Self.stepikConfigInfo?.get(for: Root.URL.version) as? String ?? ""
    static let adaptiveRatingURL = Self.stepikConfigInfo?.get(for: Root.URL.adaptiveRating) as? String ?? ""

    // Section: Cookie
    static let cookiePrefix = Self.stepikConfigInfo?.get(for: Root.Cookie.prefix) as? String ?? ""

    // Section: Feature
    static let doesAllowCourseUnenrollment = Self.stepikConfigInfo?.get(for: Root.Feature.courseUnenrollment) as? Bool ?? true
    static let inAppUpdatesAvailable = Self.stepikConfigInfo?.get(for: Root.Feature.inAppUpdates) as? Bool ?? false
    static let streaksEnabled = Self.stepikConfigInfo?.get(for: Root.Feature.streaks) as? Bool ?? true
    static let shouldRegisterNotifications = Self.stepikConfigInfo?.get(for: Root.Feature.notifications) as? Bool ?? true

    // Section: Adaptive
    static let adaptiveSupportedCourses = Self.stepikConfigInfo?.get(for: Root.Adaptive.supportedCourses) as? [Int] ?? []
    static let isAdaptive = Self.stepikConfigInfo?.get(for: Root.Adaptive.isAdaptive) as? Bool ?? false
    static let adaptiveCoursesInfoURL = Self.stepikConfigInfo?.get(for: Root.Adaptive.coursesInfoURL) as? String ?? ""

    // Section: RateApp
    struct RateApp {
        static let correctSubmissionsThreshold = StepikApplicationsInfo.stepikConfigInfo?.get(for: Root.RateApp.submissionsThreshold) as? Int ?? 4
        static let appStoreURL = URL(string: StepikApplicationsInfo.stepikConfigInfo?.get(for: Root.RateApp.appStoreLink) as? String ?? "")
    }

    // Section: Social
    struct SocialInfo {
        struct AppIds {
            static let vk = StepikApplicationsInfo.stepikConfigInfo?.get(for: Root.SocialProviders.vkId) as? String ?? ""
            static let facebook = StepikApplicationsInfo.stepikConfigInfo?.get(for: Root.SocialProviders.facebookId) as? String ?? ""
        }

        static var isSignInWithAppleAvailable: Bool {
            if #available(iOS 13.0, *) {
                return true
            } else {
                return false
            }
        }
    }

    // Section: Modules
    struct Modules {
        static let tabs = StepikApplicationsInfo.stepikConfigInfo?.get(for: Root.Modules.tabs) as? [String]
    }

    // Section: Versions
    struct Versions {
        static let stories = StepikApplicationsInfo.stepikConfigInfo?.get(for: Root.Versions.stories) as? Int
    }
}
