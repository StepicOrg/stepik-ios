//
//  Course+CoreDataProperties.swift
//  
//
//  Created by Alexander Karpov on 25.09.15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Course {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedBeginDate: NSDate?
    @NSManaged var managedCourseDescription: String?
    @NSManaged var managedTitle: String?
    @NSManaged var managedEndDate: NSDate?
    @NSManaged var managedImageURL: String?
    @NSManaged var managedEnrolled: NSNumber?
    @NSManaged var managedFeatured: NSNumber?
    
    @NSManaged var managedSummary: String?
    @NSManaged var managedWorkload: String?
    @NSManaged var managedIntroURL: String?
    @NSManaged var managedFormat: String?
    @NSManaged var managedAudience: String?
    @NSManaged var managedCertificate: String?
    @NSManaged var managedRequirements: String?

    
    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Course", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Course.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId
        }
        get {
            return managedId?.integerValue ?? -1
        }
    }
    
    var beginDate : NSDate? {
        set(date) {
            self.managedBeginDate = date
        }
        get {
            return managedBeginDate
        }
    }
    
    var courseDescription : String {
        set(description) {
            self.managedCourseDescription = description
        }
        get {
            return managedCourseDescription ?? "No description"
        }
    }
    
    var title : String {
        set(title) {
            self.managedTitle = title
        }
        get {
            return managedTitle ?? "No title" 
        }
    }
    
    var endDate: NSDate? {
        set(date){ 
            self.managedEndDate = date
        }
        get{
            return managedEndDate
        }
    }
    
    var coverURLString : String {
        set(url){
            self.managedImageURL = url
        }
        get{
            return managedImageURL ?? "http://www.yoprogramo.com/wp-content/uploads/2015/08/human-error-in-finance-640x324.jpg"
        }
    }
    
    var enrolled : Bool {
        set(enrolled) {
            self.managedEnrolled = enrolled
        }
        get {
            return managedEnrolled?.boolValue ?? false
        }
    }
    
    var featured : Bool {
        set(featured){
            self.managedFeatured = featured
        }
        get {
            return managedFeatured?.boolValue ?? false
        }
    }
    
    var summary : String {
        set(value){
            self.managedSummary = value
        }
        get {
            return managedSummary ?? "No summary"
        }
    }
    
    var workload : String {
        set(value){
            self.managedWorkload = value
        }
        get {
            return managedWorkload ?? "No workload"
        }
    }
    
    var introURL : String {
        set(value){
            self.managedIntroURL = value
        }
        get {
            return managedIntroURL ?? "http://www.yoprogramo.com/wp-content/uploads/2015/08/human-error-in-finance-640x324.jpg"
        }
    }
    
    var format : String {
        set(value){
            self.managedFormat = value
        }
        get {
            return managedFormat ?? "No format"
        }
    }
    
    var audience : String {
        set(value){
            self.managedAudience = value
        }
        get {
            return managedAudience ?? "No audience"
        }
    }
    
    var certificate : String {
        set(value){
            self.managedCertificate = value
        }
        get {
            return managedCertificate ?? "No certificate"
        }
    }
    
    var requirements : String {
        set(value){
            self.managedRequirements = value
        }
        get {
            return managedRequirements ?? "No requirements"
        }
    }
}
