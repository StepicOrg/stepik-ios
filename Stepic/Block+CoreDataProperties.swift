//
//  Block+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData
import Foundation
import UIKit

extension Block {
    @NSManaged var managedName: String?
    @NSManaged var managedText: String?

    @NSManaged var managedVideo: Video?
    @NSManaged var managedStep: Step?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Block", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: Block.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var name: String {
        get {
             self.managedName ?? "undefined"
        }
        set {
            self.managedName = newValue
        }
    }

    var text: String? {
        get {
             self.managedText
        }
        set {
            self.managedText = newValue
        }
    }

    var video: Video? {
        get {
             self.managedVideo
        }
        set {
            self.managedVideo = newValue
        }
    }

    var image: UIImage {
        switch self.type {
        case .text:
            return UIImage(named: "ic_theory_dark").require()
        case .video:
            return UIImage(named: "ic_video_dark").require()
        case .code, .dataset, .admin, .sql:
            return UIImage(named: "ic_hard_dark").require()
        default:
            return UIImage(named: "ic_easy_dark").require()
        }
    }

    var type: BlockType {
        BlockType(rawValue: self.name) ?? .text
    }

    // MARK: - Types -

    enum BlockType: String {
        case animation
        case chemical
        case choice
        case code
        case dataset
        case fillBlanks = "fill-blanks"
        case freeAnswer = "free-answer"
        case linuxCode = "linux-code"
        case matching
        case math
        case number
        case puzzle
        case pycharm
        case sorting
        case sql
        case string
        case text
        case video
        case admin

        var isTheory: Bool {
            return [BlockType.text, BlockType.video].contains(self)
        }

        var isQuiz: Bool {
            return !self.isTheory
        }
    }
}
