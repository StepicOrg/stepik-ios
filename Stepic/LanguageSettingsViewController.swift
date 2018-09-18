//
//  LanguageSettingsViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class LanguageSettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var contentLanguageService = ContentLanguageService()

    var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ContentLanguagePreferenceTableViewCell", bundle: nil), forCellReuseIdentifier: "ContentLanguagePreferenceTableViewCell")
        self.title = NSLocalizedString("ContentLanguagePreference", comment: "")
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndex = ContentLanguage.supportedLanguages.index(of: contentLanguageService.globalContentLanguage)
        selectLanguage(selectedLanguage: contentLanguageService.globalContentLanguage)
    }

    func selectLanguage(selectedLanguage: ContentLanguage) {
        contentLanguageService.globalContentLanguage = selectedLanguage

        if let selectedIndex = selectedIndex {
            let deselectIndexPath = IndexPath(row: selectedIndex, section: 0)
            let cellToDeselect = tableView.cellForRow(at: deselectIndexPath)
            cellToDeselect?.accessoryType = .none
        }
        if let selectedIndex = ContentLanguage.supportedLanguages.index(of: selectedLanguage) {
            self.selectedIndex = selectedIndex
            let selectIndexPath = IndexPath(row: selectedIndex, section: 0)
            let cellToSelect = tableView.cellForRow(at: selectIndexPath)
            cellToSelect?.accessoryType = .checkmark
        }
    }
}

extension LanguageSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectLanguage(selectedLanguage: ContentLanguage.supportedLanguages[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension LanguageSettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContentLanguage.supportedLanguages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentLanguagePreferenceTableViewCell", for: indexPath) as? ContentLanguagePreferenceTableViewCell else {
            return UITableViewCell()
        }

        cell.setup(contentLanguage: ContentLanguage.supportedLanguages[indexPath.row])
        return cell
    }
}
