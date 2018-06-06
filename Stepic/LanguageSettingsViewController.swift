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

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ContentLanguagePreferenceTableViewCell", bundle: nil), forCellReuseIdentifier: "ContentLanguagePreferenceTableViewCell")
        self.title = NSLocalizedString("ContentLanguagePreference", comment: "")
        tableView.tableFooterView = UIView()
    }

    func selectLanguage(selectedLanguage: ContentLanguage) {
        ContentLanguage.sharedContentLanguage = selectedLanguage
    }
}

extension LanguageSettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ContentLanguage.sharedContentLanguage = ContentLanguage.supportedLanguages[indexPath.row]
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
