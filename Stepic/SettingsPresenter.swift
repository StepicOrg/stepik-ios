//
//  SettingsPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol SettingsView: AnyObject {
    func setMenu(menuIDs: [SettingsMenuBlock])
    func presentAuth()
}

protocol SettingsPresenterProtocol: AnyObject {
    var view: SettingsView? { get }

    var isAdaptiveModeEnabled: Bool { get set }
    var isAutoplayModeEnabled: Bool { get set }

    func refresh()
    func logout()
}

final class SettingsPresenter: SettingsPresenterProtocol {
    weak var view: SettingsView?

    private let autoplayStorageManager: AutoplayStorageManagerProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol

    var isAdaptiveModeEnabled: Bool {
        get {
            self.adaptiveStorageManager.isAdaptiveModeEnabled
        }
        set {
            self.adaptiveStorageManager.isAdaptiveModeEnabled = newValue
        }
    }

    var isAutoplayModeEnabled: Bool {
        get {
            self.autoplayStorageManager.isAutoplayEnabled
        }
        set {
            self.autoplayStorageManager.isAutoplayEnabled = newValue
        }
    }

    private var menu: [SettingsMenuBlock] = [
        // Video
        .videoHeader,
        .loadingVideoQuality,
        .onlineVideoQuality,
        // Content language
        .languageHeader,
        .contentLanguage,
        // Learning
        .learningHeader,
        .stepFontSize,
        .codeEditorSettings,
        .autoplaySwitch,
        .adaptiveModeSwitch,
        // Downloaded content
        .downloadedContentHeader,
        .downloads,
        .deleteAllContent,
        // Other
        .otherSettingsHeader,
        .logout
    ]

    init(
        view: SettingsView,
        autoplayStorageManager: AutoplayStorageManagerProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol
    ) {
        self.view = view
        self.autoplayStorageManager = autoplayStorageManager
        self.adaptiveStorageManager = adaptiveStorageManager
    }

    func refresh() {
        self.view?.setMenu(menuIDs: self.menu)
    }

    func logout() {
        AuthInfo.shared.token = nil
        self.view?.presentAuth()
    }
}
