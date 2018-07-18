//
//  MainViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 03/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

// MARK: MainViewController: UIViewController

final class MainViewController: UIViewController {

    // MARK: - Instance Properties

    @IBOutlet var greetingLabel: UILabel!

    var presenter: MainViewPresenter!

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(presenter != nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: presenter.titleForRightBarButtonItem(),
            style: .plain,
            target: self,
            action: #selector(rightBarButtonItemPressed(_:))
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    // MARK: - Private API

    @objc private func rightBarButtonItemPressed(_ sender: Any) {
        presenter.rightBarButtonPressed()
    }
}

// MARK: - MainViewController: MainView -

extension MainViewController: MainView {
    func setTitle(_ title: String) {
        self.title = title
    }

    func setGreetingText(_ text: String) {
        greetingLabel.text = text
    }

    func setRightBarButtonItemTitle(_ title: String) {
        navigationItem.rightBarButtonItem?.title = title
    }
}
