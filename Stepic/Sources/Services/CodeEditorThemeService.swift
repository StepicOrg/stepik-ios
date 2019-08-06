import UIKit

protocol CodeEditorThemeServiceProtocol: class {
    var theme: CodeEditorTheme { get }

    func update(name: String)
}

final class CodeEditorThemeService: CodeEditorThemeServiceProtocol {
    var theme: CodeEditorTheme {
        return CodeEditorTheme(font: self.font, name: self.name)
    }

    private var font: UIFont {
        let codeElementsSize: CodeQuizElementsSize = DeviceInfo.current.isPad ? .big : .small
        let fontSize = codeElementsSize.elements.editor.realSizes.fontSize
        return UIFont(name: "Courier", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }

    private var name: String {
        get {
            return PreferencesContainer.codeEditor.theme
        }
        set {
            PreferencesContainer.codeEditor.theme = newValue
        }
    }

    func update(name: String) {
        self.name = name
    }
}
