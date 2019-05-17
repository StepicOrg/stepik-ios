import Foundation
import WebKit

protocol ContentProcessingInjection: class {
    /// Script that will be injected to <head></head>
    var headScript: String { get }
    /// Script that will be injected after <body> tag
    var bodyHeadScript: String { get }
    /// Script that will be injected before <body> tag
    var bodyTailScript: String { get }

    func shouldInject(to code: String) -> Bool
}

extension ContentProcessingInjection {
    var headScript: String {
        return ""
    }

    var bodyHeadScript: String {
        return ""
    }

    var bodyTailScript: String {
        return ""
    }

    func shouldInject(to code: String) -> Bool {
        return true
    }
}

/// Injects WYSIWYG and Stepik CSS files
final class CommonStylesInjection: ContentProcessingInjection {
    var headScript: String {
        return Scripts.styles
    }
}
