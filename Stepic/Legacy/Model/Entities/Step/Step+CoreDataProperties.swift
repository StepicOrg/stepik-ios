//
//  Step+CoreDataProperties.swift
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

extension Step {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedPosition: NSNumber?
    @NSManaged var managedStatus: String?
    @NSManaged var managedProgressId: String?
    @NSManaged var managedLessonId: NSNumber?
    @NSManaged var managedHasSubmissionRestrictions: NSNumber?
    @NSManaged var managedMaxSubmissionsCount: NSNumber?
    @NSManaged var managedPassedBy: NSNumber?
    @NSManaged var managedCorrectRatio: NSNumber?

    @NSManaged var managedAttempt: AttemptEntity?
    @NSManaged var managedBlock: Block?
    @NSManaged var managedLesson: Lesson?
    @NSManaged var managedProgress: Progress?
    @NSManaged var managedOptions: StepOptions?

    @NSManaged var managedDiscussionsCount: NSNumber?
    @NSManaged var managedDiscussionProxy: String?
    @NSManaged var managedDiscussionThreadsArray: NSObject?
    @NSManaged var managedDiscussionThreads: NSOrderedSet?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Step", in: CoreDataHelper.shared.context)!
    }

    convenience init() {
        self.init(entity: Step.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = newValue as NSNumber?
        }
    }

    var lessonID: Int {
        get {
            self.managedLessonId?.intValue ?? -1
        }
        set {
            self.managedLessonId = newValue as NSNumber?
        }
    }

    var position: Int {
        get {
            self.managedPosition?.intValue ?? -1
        }
        set {
            self.managedPosition = newValue as NSNumber?
        }
    }

    var passedByCount: Int {
        get {
            self.managedPassedBy?.intValue ?? 0
        }
        set {
            self.managedPassedBy = newValue as NSNumber?
        }
    }

    var correctRatio: Float {
        get {
            self.managedCorrectRatio?.floatValue ?? 0
        }
        set {
            self.managedCorrectRatio = newValue as NSNumber?
        }
    }

    var hasSubmissionRestrictions: Bool {
        get {
            self.managedHasSubmissionRestrictions?.boolValue ?? false
        }
        set {
            self.managedHasSubmissionRestrictions = newValue as NSNumber?
        }
    }

    var status: String {
        get {
            self.managedStatus ?? "no status"
        }
        set {
            self.managedStatus = newValue
        }
    }

    var attempt: AttemptEntity? {
        get {
            self.managedAttempt
        }
        set {
            self.managedAttempt = newValue
        }
    }

    var block: Block {
        get {
            self.managedBlock!
        }
        set {
            self.managedBlock = newValue
        }
    }

    var progressID: String? {
        get {
            self.managedProgressId
        }
        set {
            self.managedProgressId = newValue
        }
    }

    var progress: Progress? {
        get {
            self.managedProgress
        }
        set {
            self.managedProgress = newValue
        }
    }

    var discussionsCount: Int? {
        get {
            self.managedDiscussionsCount?.intValue
        }
        set {
            self.managedDiscussionsCount = newValue as NSNumber?
        }
    }

    var discussionProxyID: String? {
        get {
            self.managedDiscussionProxy
        }
        set {
            self.managedDiscussionProxy = newValue
        }
    }

    var discussionThreadsArray: [String]? {
        get {
            self.managedDiscussionThreadsArray as? [String]
        }
        set {
            self.managedDiscussionThreadsArray = newValue as NSObject?
        }
    }

    var discussionThreads: [DiscussionThread]? {
        get {
            self.managedDiscussionThreads?.array as? [DiscussionThread]
        }
        set {
            if let newDiscussionThreads = newValue {
                self.managedDiscussionThreads = NSOrderedSet(array: newDiscussionThreads)
            } else {
                self.managedDiscussionThreads = nil
            }
        }
    }

    var lesson: Lesson? {
        get {
            self.managedLesson
        }
        set {
            self.managedLesson = newValue
        }
    }

    var options: StepOptions? {
        get {
            self.managedOptions
        }
        set {
            self.managedOptions = newValue
        }
    }

    var maxSubmissionsCount: Int? {
        get {
            self.managedMaxSubmissionsCount?.intValue
        }
        set {
            self.managedMaxSubmissionsCount = newValue as NSNumber?
        }
    }
}
