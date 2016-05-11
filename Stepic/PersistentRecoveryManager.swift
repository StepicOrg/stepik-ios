//
//  PersistentRecoveryManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 All recovery managers' base class. MUST BE OVERRIDEN
 */
class PersistentRecoveryManager {
    
    var plistName : String
    
    var plistPath : String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = "\(documentsPath)/\(plistName).plist"
        if !NSFileManager.defaultManager().fileExistsAtPath(path) {
            try! NSFileManager.defaultManager().copyItemAtPath("\(NSBundle.mainBundle().bundlePath)/\(plistName).plist", toPath: path)
        }
        return path
    }
    
    init(baseName: String) {
        self.plistName = baseName
    }
    
    private func loadObjectDictionaryFromKey(key: String) -> [String: AnyObject]? {
        let plistData = NSDictionary(contentsOfFile: plistPath)!
        return plistData[key] as? [String: AnyObject] 
    }
    
    //Override this method in a subclass!
    func recoverObjectFromDictionary(dictionary: [String: AnyObject]) -> DictionarySerializable? {
        return nil
    }
    
    func recoverObjectWithKey(key: String) -> DictionarySerializable? {
        if let objectDictionary = loadObjectDictionaryFromKey(key) {
            return recoverObjectFromDictionary(objectDictionary)
        } else {
            return nil
        }
    }
    
    func writeObjectWithKey(key: String, object: DictionarySerializable) {
        let plistData = NSMutableDictionary(contentsOfFile: plistPath)!
        plistData[key] = object.serializeToDictionary()
        plistData.writeToFile(plistPath, atomically: true)
    }
    
}