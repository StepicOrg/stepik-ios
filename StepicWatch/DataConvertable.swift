//
//  DataConvertable.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 18/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import Foundation

protocol DataConvertable {
	func toDictionary() -> [String: AnyObject]
	init(dictionary: [String: AnyObject])
	init(data: Data)
}

extension DataConvertable {
	init(data: Data) {
		let dic = NSKeyedUnarchiver.unarchiveObject(with: data) as! [String: AnyObject]
		self.init(dictionary: dic)
	}

	func toData() -> Data {
		return NSKeyedArchiver.archivedData(withRootObject: self.toDictionary())
	}
}

extension Array where Element: DataConvertable {
	func toData() -> Data {
		var result: [Data] = []
		for obj in self {
			result.append(obj.toData())
		}
		return NSKeyedArchiver.archivedData(withRootObject: result)
	}

	static func fromData(data: Data) -> [Element] {
		var result: [Element] = []
		let input = NSKeyedUnarchiver.unarchiveObject(with: data) as! [Data]
		for el in input {
			result.append(Element(data: el))
		}
		return result
	}

}
