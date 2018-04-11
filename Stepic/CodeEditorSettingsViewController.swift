//
//  CodeEditorSettingsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.04.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import UIKit
import ActionSheetPicker_3_0

class CodeEditorSettingsViewController: MenuViewController, CodeEditorSettingsView {
    var presenter: CodeEditorSettingsPresenter?
    var previewView: CodeEditorPreviewView!

    override func viewDidLoad() {
        super.viewDidLoad()

        previewView = CodeEditorPreviewView()
        tableView.tableHeaderView = previewView
        layoutTableHeaderView()

        presenter = CodeEditorSettingsPresenter(view: self)
    }

    func chooseEditorTheme(current: String) {
        guard let hl = previewView.highlightr else { return }

        ActionSheetStringPicker.show(withTitle: "Выберите тему",
            rows: hl.availableThemes(),
            initialSelection: hl.availableThemes().index(of: current)!,
            doneBlock: { _, _, _ in

            },
            cancel: { _ in return
            },
            origin: tableView)
    }

    func chooseFontSize(current: Int) {
        guard let hl = previewView.highlightr else { return }

        ActionSheetStringPicker.show(withTitle: "Выберите размер шрифта",
            rows: (10...20).map { "\($0)"},
            initialSelection: 5,
            doneBlock: { _, _, _ in

            },
            cancel: { _ in return
            },
            origin: tableView)
    }

    func setMenu(menu: Menu) {
        self.menu = menu
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        layoutTableHeaderView()
    }

    func layoutTableHeaderView() {
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let headerWidth = headerView.bounds.size.width
        let widthConstraint = headerView.widthAnchor.constraint(equalToConstant: headerWidth)
        widthConstraint.isActive = true

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        var frame = headerView.frame
        frame.size.height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        headerView.frame = frame

        headerView.removeConstraint(widthConstraint)
        headerView.translatesAutoresizingMaskIntoConstraints = true
        tableView.tableHeaderView = headerView
    }
}
