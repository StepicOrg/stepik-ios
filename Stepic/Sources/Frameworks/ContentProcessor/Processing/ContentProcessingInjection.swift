import UIKit
import WebKit

protocol ContentProcessingInjection: AnyObject {
    /// Script that will be injected to <head></head>
    var headScript: String { get }
    /// Script that will be injected after <body> tag
    var bodyHeadScript: String { get }
    /// Script that will be injected before <body> tag
    var bodyTailScript: String { get }

    func shouldInject(to code: String) -> Bool
}

extension ContentProcessingInjection {
    var headScript: String { "" }

    var bodyHeadScript: String { "" }

    var bodyTailScript: String { "" }

    func shouldInject(to code: String) -> Bool { true }
}

/// Injects WYSIWYG and Stepik CSS files
final class CommonStylesInjection: ContentProcessingInjection {
    var headScript: String { Scripts.styles }
}

/// Injects meta-viewport
final class MetaViewportInjection: ContentProcessingInjection {
    var headScript: String { Scripts.metaViewport }
}

/// Clickable images
final class ClickableImagesInjection: ContentProcessingInjection {
    var headScript: String { Scripts.clickableImages }

    func shouldInject(to code: String) -> Bool {
        code.contains("<img")
    }
}

/// Disable images callout on long tap
final class WebkitImagesCalloutDisableInjection: ContentProcessingInjection {
    var headScript: String { Scripts.webkitCalloutDisable }
}

/// MathJax init script
final class MathJaxInjection: ContentProcessingInjection {
    var headScript: String { Scripts.localMathJax }

    func shouldInject(to code: String) -> Bool {
        code.filter { $0 == "$" }.count >= 2
            || (code.contains("\\[") && code.contains("\\]"))
            || (code.contains("math-tex"))
    }
}

/// Detect web scripts
final class WebScriptInjection: ContentProcessingInjection {
    func shouldInject(to code: String) -> Bool {
        code.contains("wysiwyg-") ||
        code.contains("<h1") ||
        code.contains("<h2") ||
        code.contains("<h3") ||
        code.contains("<h4") ||
        code.contains("<h5") ||
        code.contains("<h6") ||
        code.contains("<img") ||
        code.contains("<iframe") ||
        code.contains("<audio") ||
        code.contains("<table") ||
        code.contains("<div") ||
        code.contains("<blockquote")
    }
}

/// Kotlin runnable code playground
final class KotlinRunnableSamplesInjection: ContentProcessingInjection {
    var headScript: String { Scripts.localKotlinPlayground }

    func shouldInject(to code: String) -> Bool {
        code.contains("<kotlin-runnable")
    }
}

/// Code syntax highlight with highlight.js
final class HightlightJSInjection: ContentProcessingInjection {
    var headScript: String { Scripts.highlightJS }

    func shouldInject(to code: String) -> Bool {
        code.contains("<code")
    }
}

/// Code syntax highlight with highlight.js
final class CustomAudioControlInjection: ContentProcessingInjection {
    var headScript: String { Scripts.audioTagWrapper }

    var bodyTailScript: String { Scripts.audioTagWrapperInit }

    func shouldInject(to code: String) -> Bool {
        code.contains("<audio")
    }
}

/// Injects script that assigns font sizes.
final class FontSizeInjection: ContentProcessingInjection {
    private static let defaultBodyFontSize = 17
    private static let defaultH1FontSize = 28
    private static let defaultH2FontSize = 22
    private static let defaultH3FontSize = 20
    private static let defaultBlockquoteFontSize = 17

    private let bodyFontSizeStringValue: String
    private let h1FontSizeStringValue: String
    private let h2FontSizeStringValue: String
    private let h3FontSizeStringValue: String
    private let blockquoteFontSizeStringValue: String

    var bodyHeadScript: String {
        """
        <script type="text/javascript">
            document.documentElement.style.setProperty('--body-font-size', '\(self.bodyFontSizeStringValue)');
            document.documentElement.style.setProperty('--h1-font-size', '\(self.h1FontSizeStringValue)');
            document.documentElement.style.setProperty('--h2-font-size', '\(self.h2FontSizeStringValue)');
            document.documentElement.style.setProperty('--h3-font-size', '\(self.h3FontSizeStringValue)');
            document.documentElement.style.setProperty('--blockquote-font-size', '\(self.blockquoteFontSizeStringValue)');
        </script>
        """
    }

    init(
        bodyFontSizeStringValue: String,
        h1FontSizeStringValue: String,
        h2FontSizeStringValue: String,
        h3FontSizeStringValue: String,
        blockquoteFontSizeStringValue: String
    ) {
        self.bodyFontSizeStringValue = bodyFontSizeStringValue
        self.h1FontSizeStringValue = h1FontSizeStringValue
        self.h2FontSizeStringValue = h2FontSizeStringValue
        self.h3FontSizeStringValue = h3FontSizeStringValue
        self.blockquoteFontSizeStringValue = blockquoteFontSizeStringValue
    }

    convenience init(
        bodyFontSize: Int = FontSizeInjection.defaultBodyFontSize,
        h1FontSize: Int = FontSizeInjection.defaultH1FontSize,
        h2FontSize: Int = FontSizeInjection.defaultH2FontSize,
        h3FontSize: Int = FontSizeInjection.defaultH3FontSize,
        blockquoteFontSize: Int = FontSizeInjection.defaultBlockquoteFontSize
    ) {
        self.init(
            bodyFontSizeStringValue: String(bodyFontSize),
            h1FontSizeStringValue: String(h1FontSize),
            h2FontSizeStringValue: String(h2FontSize),
            h3FontSizeStringValue: String(h3FontSize),
            blockquoteFontSizeStringValue: String(blockquoteFontSize)
        )
    }

    convenience init(baseFontSize: Int) {
        self.init(
            bodyFontSize: baseFontSize,
            h1FontSize: Int((Float(baseFontSize) * 1.65).rounded()),
            h2FontSize: Int((Float(baseFontSize) * 1.3).rounded()),
            h3FontSize: Int((Float(baseFontSize) * 1.2).rounded()),
            blockquoteFontSize: baseFontSize
        )
    }

    convenience init(stepFontSize: StepFontSize) {
        self.init(
            bodyFontSizeStringValue: stepFontSize.body,
            h1FontSizeStringValue: stepFontSize.h1,
            h2FontSizeStringValue: stepFontSize.h2,
            h3FontSizeStringValue: stepFontSize.h3,
            blockquoteFontSizeStringValue: stepFontSize.blockquote
        )
    }
}

/// Injects script that assigns text color for light and dark mode.
final class TextColorInjection: ContentProcessingInjection {
    private let lightColorHexString: String
    private let darkColorHexString: String

    var bodyHeadScript: String {
        """
        <script type="text/javascript">
            document.body.style.setProperty('--text-color-light', '#\(self.lightColorHexString)');
            document.body.style.setProperty('--text-color-dark', '#\(self.darkColorHexString)');
        </script>
        """
    }

    init(lightColorHexString: String, darkColorHexString: String) {
        self.lightColorHexString = lightColorHexString
        self.darkColorHexString = darkColorHexString
    }

    convenience init(lightColor: UIColor, darkColor: UIColor) {
        self.init(lightColorHexString: lightColor.hexString, darkColorHexString: darkColor.hexString)
    }

    convenience init(dynamicColor: UIColor) {
        if #available(iOS 13.0, *) {
            let lightTraitCollection = UITraitCollection(traitsFrom: [.current, .init(userInterfaceStyle: .light)])
            let darkTraitCollection = UITraitCollection(traitsFrom: [.current, .init(userInterfaceStyle: .dark)])

            let lightColor = dynamicColor.resolvedColor(with: lightTraitCollection)
            let darkColor = dynamicColor.resolvedColor(with: darkTraitCollection)

            self.init(lightColor: lightColor, darkColor: darkColor)
        } else {
            self.init(lightColor: dynamicColor, darkColor: dynamicColor)
        }
    }
}
