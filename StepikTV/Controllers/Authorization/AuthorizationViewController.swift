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

  @IBOutlet var upperButton: StandardButton!
  @IBOutlet var midButton: StandardButton!
  @IBOutlet var lowerButton: StandardButton!

  var nameLabel: UILabel = UILabel()
  var exitButton: StandardButton = StandardButton() {
    didSet {
      exitButton.titleLabel?.text = "Exit"
    }
  }
  var settingsButton: StandardButton = StandardButton() {
    didSet {
      settingsButton.titleLabel?.text = "Settings"
    }
  }

  var presenter: AuthorizationPresenter?

  override func awakeFromNib() {
    super.awakeFromNib()
    self.presenter = AuthorizationPresenter(view: self, authAPI: AuthAPI(), stepicsAPI: StepicsAPI())
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

    stackView.addArrangedSubview(nameLabel)
    stackView.addArrangedSubview(exitButton)
    stackView.addArrangedSubview(settingsButton)
  }

  func cleanStackView() {
    for arrangedView in stackView.arrangedSubviews {
      stackView.removeArrangedSubview(arrangedView)
      arrangedView.removeFromSuperview()
    }
  }
}
