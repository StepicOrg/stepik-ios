//
//  CourseInfoInterfaceController.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 17/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import WatchKit
import Foundation

extension CourseInfoInterfaceController: WatchSessionDataObserver {
  var keysForObserving: [WatchSessionSender.Name] {
    return [.Metainfo]
  }

  func recieved(data: Any, forKey key: WatchSessionSender.Name) {
    if key == .Metainfo {
      let container = CourseMetainfoContainer(data: data as! Data)
      UserDefaults.standard.set(data, forKey: WatchSessionSender.Name.Metainfo(courseId: container.courseId).rawValue)

      if container.courseId == course.id {
        updateTable()
      }
    }
  }
}

class CourseInfoInterfaceController: WKInterfaceController {

  @IBOutlet var table: WKInterfaceTable!
  var course: CoursePlainEntity!
  var metainfo: [CourseMetainfoEntity] = []

  override func awake(withContext context: Any?) {
    super.awake(withContext: context)

    WatchSessionManager.sharedManager.addObserver(self)

    self.course = context as! CoursePlainEntity
  }

  func updateTable() {
    if let data = UserDefaults.standard.object(forKey: WatchSessionSender.Name.Metainfo(courseId: course.id).rawValue) {
      let container = CourseMetainfoContainer(data: data as! Data)
      metainfo = container.metainfo
    }

    let count = metainfo.count + 1
    table.setNumberOfRows(count, withRowType: "InfoCell")
    for (index, cellInfo) in metainfo.enumerated() {
      let cell = table.rowController(at: index + 1) as! DataRowType
      cell.titleLabel.setText(cellInfo.title)
      cell.subtitleLabel.setText(cellInfo.subtitle)
    }

    let cell = table.rowController(at: 0) as! DataRowType
    cell.titleLabel.setText("Завершение курса")
    cell.subtitleLabel.setText(course.metainfo)
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
    updateTable()
  }

  override func willDisappear() {
    super.willDisappear()

    WatchSessionManager.sharedManager.removeObserver(self)
  }
}
