import UIKit

protocol CodeEditorThemeServiceProtocol: AnyObject {
    var theme: CodeEditorTheme { get }

    func update(name: String)
}

// FIXME: Migrate to StorageManager
final class CodeEditorThemeService: CodeEditorThemeServiceProtocol {
    var theme: CodeEditorTheme { CodeEditorTheme(font: self.font, name: self.name) }

    private var font: UIFont {
        let codeElementsSize: CodeQuizElementsSize = DeviceInfo.current.isPad ? .big : .small
        let fontSize = codeElementsSize.elements.editor.realSizes.fontSize
        return UIFont(name: "Courier", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    private var name: String {
        get {
            // TODO: Remove PreferencesContainer.
            PreferencesContainer.codeEditor.theme
        }
        set {
            PreferencesContainer.codeEditor.theme = newValue
        }
    }

    func update(name: String) {
        self.name = name
    }
}
