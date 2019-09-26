//
//  LanguageSettingsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

@available(*, deprecated, message: "Class to initialize content language settings w/o storyboards logic")
final class LanguageSettingsLegacyAssembly: Assembly {
    func makeModule() -> UIViewController {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "LanguageSettingsViewController",
            storyboardName: "Profile"
        ) as? LanguageSettingsViewController else {
            fatalError("Failed to initialize LanguageSettingsViewController")
        }

        return viewController
    }
}

final class LanguageSettingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private var contentLanguageService = ContentLanguageService()

    private var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("ContentLanguagePreference", comment: "")

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(
            UINib(nibName: "ContentLanguagePreferenceTableViewCell", bundle: nil),
            forCellReuseIdentifier: "ContentLanguagePreferenceTableViewCell"
        )
        self.tableView.tableFooterView = UIView()

        self.edgesForExtendedLayout = []

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.selectedIndex = ContentLanguage.supportedLanguages.index(
            of: self.contentLanguageService.globalContentLanguage
        )
        self.selectLanguage(self.contentLanguageService.globalContentLanguage)
    }

    private func selectLanguage(_ language: ContentLanguage) {
        self.contentLanguageService.globalContentLanguage = language

        if let selectedIndex = self.selectedIndex {
            let deselectIndexPath = IndexPath(row: selectedIndex, section: 0)
            let cellToDeselect = self.tableView.cellForRow(at: deselectIndexPath)
            cellToDeselect?.accessoryType = .none
        }
        if let selectedIndex = ContentLanguage.supportedLanguages.index(of: language) {
            self.selectedIndex = selectedIndex
            let selectIndexPath = IndexPath(row: selectedIndex, section: 0)
            let cellToSelect = self.tableView.cellForRow(at: selectIndexPath)
            cellToSelect?.accessoryType = .checkmark
        }
    }
}

extension LanguageSettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContentLanguage.supportedLanguages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ContentLanguagePreferenceTableViewCell",
            for: indexPath
        ) as? ContentLanguagePreferenceTableViewCell else {
            return UITableViewCell()
        }

        cell.title = ContentLanguage.supportedLanguages[indexPath.row].fullString

        return cell
    }
}

extension LanguageSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectLanguage(ContentLanguage.supportedLanguages[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
