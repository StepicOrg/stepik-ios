import Foundation

protocol PromoBannersServiceProtocol: AnyObject {
    func getPromoBanners() -> [PromoBanner]
}

extension PromoBannersServiceProtocol {
    func getPromoBanners(language: ContentLanguage, screen: PromoBanner.ScreenType) -> [PromoBanner] {
        self.getPromoBanners().filter { $0.lang == language.languageString && $0.screenType == screen }
    }
}

final class PromoBannersService: PromoBannersServiceProtocol {
    private let remoteConfig: RemoteConfig

    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
    }

    func getPromoBanners() -> [PromoBanner] {
        guard let promoBannersStringValue = self.remoteConfig.promoBannersStringValue,
              let data = promoBannersStringValue.data(using: .utf8),
              !data.isEmpty else {
            return []
        }

        do {
            let decoder = JSONDecoder()

            let promoBanners = try decoder.decode([PromoBanner].self, from: data)
            let supportedPromoBanners = promoBanners.filter {
                $0.colorType != nil && $0.screenType != nil && $0.position >= 0
            }

            return supportedPromoBanners
        } catch {
            print("PromoBannersService :: failed decode with error = \(error)")
            return []
        }
    }
}
