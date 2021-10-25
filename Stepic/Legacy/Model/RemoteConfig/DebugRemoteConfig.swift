import Foundation

final class DebugRemoteConfig {
    private static let userDefaultsKeyPrefix = "remote_config_"

    static let shared = DebugRemoteConfig()

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getValueForKey(_ key: RemoteConfig.Key) -> Any? {
        self.userDefaults.object(forKey: self.makeUserDefaultsKey(key))
    }

    func setValue(_ value: Any?, forKey key: RemoteConfig.Key) {
        self.userDefaults.set(value, forKey: self.makeUserDefaultsKey(key))
    }

    private func makeUserDefaultsKey(_ remoteConfigKey: RemoteConfig.Key) -> String {
        "\(Self.userDefaultsKeyPrefix)\(remoteConfigKey.rawValue)"
    }
}

extension DebugRemoteConfig: RemoteConfigDelegate {
    func remoteConfig(_ remoteConfig: RemoteConfig, configValueForKey key: RemoteConfig.Key) -> Any? {
        self.getValueForKey(key)
    }
}
