//
//  VideoTransformationPolicy.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

class VideoTransformationPolicy: NSEntityMigrationPolicy {
    private static let sourceCachedQualityKey = "managedCachedQuality"
    private static let destinationCachedQualityKey = "managedQuality"
    private static let cachedVideoFileName = "CachedVideoFile"

    override func createDestinationInstances(forSource sInstance: NSManagedObject, in mapping: NSEntityMapping, manager: NSMigrationManager) throws {
        try super.createDestinationInstances(forSource: sInstance, in: mapping, manager: manager)

        guard let cachedQuality = sInstance.value(forKey: VideoTransformationPolicy.sourceCachedQualityKey) as? NSString else {
            return
        }

        guard let cachedVideoFile = manager.destinationInstances(forEntityMappingName: mapping.name, sourceInstances: [sInstance]).first else {
            return
        }

        guard let context = cachedVideoFile.managedObjectContext else {
            return
        }

        let object = NSEntityDescription.insertNewObject(forEntityName: VideoTransformationPolicy.cachedVideoFileName, into: context)
        object.setValue(cachedQuality, forKey: VideoTransformationPolicy.destinationCachedQualityKey)
    }
}
