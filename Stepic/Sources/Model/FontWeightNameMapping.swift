import Foundation

enum FontWeightNameMapping: Int, CaseIterable {
    case ultraLight = 100
    case thin = 200
    case light = 300
    case regular = 400
    case medium = 500
    case semiBold = 600
    case bold = 700
    case heavy = 800
    case black = 900

    var name: String {
        switch self {
        case .ultraLight:
            return "UltraLight"
        case .thin:
            return "Thin"
        case .light:
            return "Light"
        case .regular:
            return "Regular"
        case .medium:
            return "Medium"
        case .semiBold:
            return "Semibold"
        case .bold:
            return "Bold"
        case .heavy:
            return "Heavy"
        case .black:
            return "Black"
        }
    }

    init?(fontFace: String) {
        let lowercasedFontFace = fontFace.lowercased()

        for fontWeight in Self.allCases {
            if lowercasedFontFace.contains(fontWeight.name.lowercased()) {
                self = fontWeight
                return
            }
        }

        return nil
    }
}
