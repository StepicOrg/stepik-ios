//
//  CoursesInterfaceController.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 17/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import WatchKit
import Foundation

extension CoursesInterfaceController: WatchSessionDataObserver {
    var keysForObserving: [WatchSessionSender.Name] {
        return [.Courses]
    }

    func recieved(data: Any, forKey key: WatchSessionSender.Name) {
        if key == .Courses {
            UserDefaults.standard.set(data, forKey: WatchSessionSender.Name.Courses.rawValue)
            let courses = Array<CoursePlainEntity>.fromData(data: data as! Data)
            self.courses = courses
        }
    }
}

class CoursesInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    var courses: [CoursePlainEntity] = [] {
        didSet {
            updateCourses()
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        WatchSessionManager.sharedManager.addObserver(self)
    }

    func updateCourses() {
        if courses.count == 0 {
            table.setNumberOfRows(1, withRowType: "InfoCell")
            let cell = table.rowController(at: 0) as! DataRowType
            let wasConnection = UserDefaults.standard.object(forKey: WatchSessionSender.Name.Courses.rawValue) != nil
            cell.titleLabel.setText(wasConnection ? "Нет доступных курсов" : "Подключите айфон для первоначальной настройки")
            return
        }

        table.setNumberOfRows(courses.count, withRowType: "CourseCell")
        for (index, cellInfo) in courses.enumerated() {
            let cell = table.rowController(at: index) as! CourseRowType
            cell.nameLabel.setText(cellInfo.name)
            cell.metainfoLabel.setText(cellInfo.metainfo)

            cell.image.setImageNamed("img_animation_")
            cell.image.startAnimatingWithImages(in: NSRange(1..<11), duration: 1, repeatCount: -1)

            cell.image.setImageWithUrl(urlString: cellInfo.imageURL)
        }
    }

    override func willActivate() {
        if let data = UserDefaults.standard.object(forKey: WatchSessionSender.Name.Courses.rawValue) {
            self.courses = Array<CoursePlainEntity>.fromData(data: data as! Data)
        }
        updateCourses()
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }



    @IBAction func controlPlaybackAction() {
        self.pushController(withName: "Playback", context: nil)
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}

public extension WKInterfaceImage {

    public func setImageWithUrl(urlString: String) {

        DispatchQueue(label: "label").async {
            if let url = NSURL(string: urlString) {

                let request = NSURLRequest(url: url as URL)
                let config = URLSessionConfiguration.default
                let session = URLSession(configuration: config)

                let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
                    if let imageData = data as Data? {
                        DispatchQueue.main.async {
                            self.setImageData(imageData)
                        }
                    }
                });
                
                task.resume()
            }
        }
    }
}
