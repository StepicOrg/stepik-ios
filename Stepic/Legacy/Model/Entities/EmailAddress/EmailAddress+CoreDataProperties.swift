//
//  EmailAddress+CoreDataProperties.swift
//  Stepic
//
//  Created by Ivan Magda on 10/9/19.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension EmailAddress {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedEmail: String?
    @NSManaged var managedIsVerified: NSNumber?
    @NSManaged var managedIsPrimary: NSNumber?

    @NSManaged var managedProfile: Profile?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "EmailAddress", in: CoreDataHelper.shared.context)!
    }

    convenience init() {
        self.init(entity: EmailAddress.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        get {
             self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = newValue as NSNumber?
        }
    }

    var userID: Int {
        get {
             self.managedUserId?.intValue ?? -1
        }
        set {
            self.managedUserId = newValue as NSNumber?
        }
    }

    var email: String {
        get {
             self.managedEmail ?? ""
        }
        set {
            self.managedEmail = newValue
        }
    }

    var isVerified: Bool {
        get {
             self.managedIsVerified?.boolValue ?? false
        }
        set {
            self.managedIsVerified = newValue as NSNumber?
        }
    }

    var isPrimary: Bool {
        get {
             self.managedIsPrimary?.boolValue ?? false
        }
        set {
            self.managedIsPrimary = newValue as NSNumber?
        }
    }

    var profile: Profile? {
        get {
             self.managedProfile
        }
        set {
            self.managedProfile = newValue
        }
    }
}
