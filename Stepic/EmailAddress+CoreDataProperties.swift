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
        return NSEntityDescription.entity(forEntityName: "EmailAddress", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: EmailAddress.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var id: Int {
        get {
            return self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = newValue as NSNumber?
        }
    }

    var userID: Int {
        get {
            return self.managedUserId?.intValue ?? -1
        }
        set {
            self.managedUserId = newValue as NSNumber?
        }
    }

    var email: String {
        get {
            return self.managedEmail ?? ""
        }
        set {
            self.managedEmail = newValue
        }
    }

    var isVerified: Bool {
        get {
            return self.managedIsVerified?.boolValue ?? false
        }
        set {
            self.managedIsVerified = newValue as NSNumber?
        }
    }

    var isPrimary: Bool {
        get {
            return self.managedIsPrimary?.boolValue ?? false
        }
        set {
            self.managedIsPrimary = newValue as NSNumber?
        }
    }

    var profile: Profile? {
        get {
            return self.managedProfile
        }
        set {
            self.managedProfile = newValue
        }
    }
}
