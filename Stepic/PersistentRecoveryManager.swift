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

    var plistName: String

    var plistPath: String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = "\(documentsPath)/\(plistName).plist"
        if !FileManager.default.fileExists(atPath: path) {
            try! FileManager.default.copyItem(atPath: "\(Bundle.main.bundlePath)/\(plistName).plist", toPath: path)
        }
        return path
    }

    init(baseName: String) {
        self.plistName = baseName
    }

    fileprivate func loadObjectDictionaryFromKey(_ key: String) -> [String: Any]? {
        let plistData = NSDictionary(contentsOfFile: plistPath)!
        return plistData[key] as? [String: Any]
    }

    //Override this method in a subclass!
    func recoverObjectFromDictionary(_ dictionary: [String: Any]) -> DictionarySerializable? {
        return nil
    }

    func recoverObjectWithKey(_ key: String) -> DictionarySerializable? {
        if let objectDictionary = loadObjectDictionaryFromKey(key) {
            return recoverObjectFromDictionary(objectDictionary)
        } else {
            return nil
        }
    }

    func writeObjectWithKey(_ key: String, object: DictionarySerializable) {
        let plistData = NSMutableDictionary(contentsOfFile: plistPath)!
        plistData[key] = object.serializeToDictionary()
        plistData.write(toFile: plistPath, atomically: true)
    }

}
