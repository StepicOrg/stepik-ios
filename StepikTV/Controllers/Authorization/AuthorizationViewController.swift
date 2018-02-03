//
//  ProfileViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet var upperButton: TVTextButton!
    @IBOutlet var midButton: TVTextButton!
    @IBOutlet var lowerButton: TVTextButton!

    var nameLabel: UILabel = UILabel()
    var exitButton: TVTextButton = TVTextButton()
    var settingsButton: TVTextButton = TVTextButton()

    var presenter: AuthorizationPresenter?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.presenter = AuthorizationPresenter(view: self, authAPI: AuthAPI(), stepicsAPI: StepicsAPI())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        exitButton.setTitle("Exit", for: .normal)
        settingsButton.setTitle("Settings", for: .normal)

        exitButton.addTarget(self, action: #selector(logoutAction(_:)), for: UIControlEvents.primaryActionTriggered)

        presenter?.checkForCachedUser()
    }

    @IBAction func loginAction(_ sender: UIButton) {
        presenter?.loginAction()
    }

    @IBAction func registerAction(_ sender: UIButton) {
        presenter?.registerAction()
    }

    @IBAction func remoteLoginAciton(_ sender: UIButton) {
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
          imageView.sd_setImage(with: avatarUrl, completed: nil)
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

        stackView.addArrangedSubview(upperButton)
        stackView.addArrangedSubview(midButton)
        stackView.addArrangedSubview(lowerButton)
    }

    func cleanStackView() {
        for arrangedView in stackView.arrangedSubviews {
          stackView.removeArrangedSubview(arrangedView)
          arrangedView.removeFromSuperview()
        }
    }
}
