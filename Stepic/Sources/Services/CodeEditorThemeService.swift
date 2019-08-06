import UIKit

protocol CodeEditorThemeServiceProtocol: class {
    var font: UIFont { get }
    /// Theme name to use for highlighting.
    var name: String { get set }
}

final class CodeEditorThemeService: CodeEditorThemeServiceProtocol {
    var font: UIFont {
        let codeElementsSize: CodeQuizElementsSize = DeviceInfo.current.isPad ? .big : .small
        let fontSize = codeElementsSize.elements.editor.realSizes.fontSize
        return UIFont(name: "Courier", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    var name: String {
        get {
            return PreferencesContainer.codeEditor.theme
        }
        set {
            PreferencesContainer.codeEditor.theme = newValue
        }
    }
}
