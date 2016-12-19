//
//  CourseEntity.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 17/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import Foundation
import CoreGraphics

@available(iOS 9.0, *)
extension WatchSessionSender.Name {
	static let RequestCourses = WatchSessionSender.Name("RequestCourses")
	static let Courses = WatchSessionSender.Name("Courses")
}

class CoursePlainEntity: DataConvertable {
    var id: Int
	var name: String
	var metainfo: String
	var imageURL: String
    var dealine: CGFloat

    var hasDeadline: Bool {
        return dealine != 0
    }
	
    init(id: Int, name: String, metainfo: String, imageURL: String, dealine: CGFloat?) {
        self.id = id
		self.name = name
		self.metainfo = metainfo
		self.imageURL = imageURL
        self.dealine = dealine ?? 0
	}
	
	required init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as! Int
		self.name = dictionary["name"] as! String
		self.metainfo = dictionary["metainfo"] as! String
		self.imageURL = dictionary["imageURL"] as! String
        self.dealine = dictionary["dealine"] as! CGFloat
	}
	
	func toDictionary() -> [String: AnyObject] {
		return ["id": id as AnyObject,
                "name": name as AnyObject,
		        "metainfo": metainfo as AnyObject,
		        "imageURL": imageURL as AnyObject,
		        "dealine": dealine as AnyObject]
	}
}
