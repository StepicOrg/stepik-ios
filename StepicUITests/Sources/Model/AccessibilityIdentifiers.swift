import Foundation

enum AccessibilityIdentifiers {
    // MARK: - Onboarding -

    enum Onboarding {
        static let closeButton = "closeOnbordingButton"

        static let nextButton = "nextButton"
    }

    // MARK: - Placeholders -

    enum Placeholders {
        static let loginButton = "loginButton"
    }

    // MARK: - AuthEmail -

    enum AuthEmail {
        static let emailTextField = "emailTextField"

        static let passwordTextField = "passwordTextField"

        static let logInButton = "logInButton"
    }

    // MARK: - AuthSocial -

    enum AuthSocial {
        static let signUpButton = "signUpButton"

        static let signInButton = "signInButton"
    }

    // MARK: - Registration -

    enum Registration {
        static let nameTextField = "nameTextField"

        static let emailTextField = "emailTextField"

        static let passwordTextField = "passwordTextField"

        static let registerButton = "registerButton"
    }

    // MARK: - TabBar -

    enum TabBar {
        static let profile = "Profile"

        static let home = "Home"

        static let notifications = "Notifications"

        static let catalog = "Catalog"

        static let debug = "Debug"
    }

    // MARK: - Settings -

    enum Settings {
        static let logOut = "logOut"
    }

    // MARK: - Profile -

    enum Profile {
        static let settingsButton = "settingsButton"
    }
}
