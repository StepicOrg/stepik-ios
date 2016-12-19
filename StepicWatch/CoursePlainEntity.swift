//
//  CourseEntity.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 17/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import Foundation

@available(iOS 9.0, *)
extension WatchSessionSender.Name {
	static let RequestCourses = WatchSessionSender.Name("RequestCourses")
	static let Courses = WatchSessionSender.Name("Courses")
}

class CoursePlainEntity: DataConvertable {
	var name: String = ""
	var metainfo: String = ""
	var imageURL: String = ""
	
	init(name: String, metainfo: String, imageURL: String) {
		self.name = name
		self.metainfo = metainfo
		self.imageURL = imageURL
	}
	
	required init(dictionary: [String: AnyObject]) {
		self.name = dictionary["name"] as! String
		self.metainfo = dictionary["metainfo"] as! String
		self.imageURL = dictionary["imageURL"] as! String
	}
	
	func toDictionary() -> [String: AnyObject] {
		return ["name": name as AnyObject,
		        "metainfo": metainfo as AnyObject,
		        "imageURL": imageURL as AnyObject]
	}
}
