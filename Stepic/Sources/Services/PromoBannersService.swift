import Foundation

protocol PromoBannersServiceProtocol: AnyObject {
    func getPromoBanners() -> [PromoBanner]
}

extension PromoBannersServiceProtocol {
    func getRussianPromoBanners() -> [PromoBanner] { self.getPromoBanners().russianPromoBanners() }

    func getEnglishPromoBanners() -> [PromoBanner] { self.getPromoBanners().englishPromoBanners() }
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
            return promoBanners
        } catch {
            print("PromoBannersService :: failed decode with error = \(error)")
            return []
        }
    }
}

// MARK: - Sequence where Element == PromoBanner -

extension Sequence where Element == PromoBanner {
    func russianPromoBanners() -> [PromoBanner] { self.promoBanners(for: .russian) }

    func englishPromoBanners() -> [PromoBanner] { self.promoBanners(for: .english) }

    private func promoBanners(for contentLanguage: ContentLanguage) -> [PromoBanner] {
        self.filter { $0.lang == contentLanguage.languageString }
    }
}
