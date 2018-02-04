//
//  ProfileViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var stackView: UIStackView!

    fileprivate var nameLabel: UILabel = UILabel()
    fileprivate var loginButton: TVTextButton = TVTextButton()
    fileprivate var signupButton: TVTextButton = TVTextButton()
    fileprivate var settingsButton: TVTextButton = TVTextButton()
    fileprivate var exitButton: TVTextButton = TVTextButton()

    var presenter: AuthorizationPresenter?

    private let screenTitle = NSLocalizedString("Profile", comment: "")
    private let loginTitle = NSLocalizedString("Log In", comment: "")
    private let signupTitle = NSLocalizedString("Sign Up", comment: "")
    private let settingsTitle = NSLocalizedString("Settings", comment: "")
    private let exitTitle = NSLocalizedString("Exit", comment: "")

    override func awakeFromNib() {
        super.awakeFromNib()
        self.presenter = AuthorizationPresenter(view: self, authAPI: AuthAPI(), stepicsAPI: StepicsAPI())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.setRoundedCorners(cornerRadius: profileImage.bounds.height / 2)

        titleLabel.text = screenTitle

        loginButton.setTitle(loginTitle, for: .normal)
        signupButton.setTitle(signupTitle, for: .normal)
        exitButton.setTitle(exitTitle, for: .normal)
        settingsButton.setTitle(settingsTitle, for: .normal)

        loginButton.addTarget(self, action: #selector(loginAction(_:)), for: UIControlEvents.primaryActionTriggered)
        signupButton.addTarget(self, action: #selector(registerAction(_:)), for: UIControlEvents.primaryActionTriggered)
        exitButton.addTarget(self, action: #selector(logoutAction(_:)), for: UIControlEvents.primaryActionTriggered)

        presenter?.checkForCachedUser()
    }

    func loginAction(_ sender: UIButton) {
        presenter?.loginAction()
    }

    func registerAction(_ sender: UIButton) {
        presenter?.registerAction()
    }

    func remoteLoginAciton(_ sender: UIButton) {
        presenter?.remoteLoginAction()
    }

    func logoutAction(_ sender: UIButton) {
        presenter?.logoutAction()
    }
}

extension AuthorizationViewController: AuthorizationView {

    func show(alert: AuthorizationAlert) {
        alert.show(in: self)
    }

    func showProfile(for user: User) {
        if let avatarUrl = URL(string: user.avatarURL) {
            profileImage.setImageWithURL(url: avatarUrl, placeholder: UIImage())
        }

        cleanStackView()

        nameLabel.text = "\(user.firstName) \(user.lastName)"

        exitButton.heightAnchor.constraint(equalToConstant: 66.0).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 66.0).isActive = true

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(exitButton)
        stackView.addArrangedSubview(settingsButton)
    }

    func showNoProfile() {
        cleanStackView()

        loginButton.heightAnchor.constraint(equalToConstant: 66.0).isActive = true
        signupButton.heightAnchor.constraint(equalToConstant: 66.0).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 66.0).isActive = true

        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(signupButton)
        stackView.addArrangedSubview(settingsButton)
    }

    func cleanStackView() {
        for arrangedView in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(arrangedView)
            arrangedView.removeFromSuperview()
        }
    }
}
