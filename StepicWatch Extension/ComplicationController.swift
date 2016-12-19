//
//  ComplicationController.swift
//  StepicWatch Extension
//
//  Created by Alexander Zimin on 19/12/2016.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
  
    // I ASSUME IT'S SORTED BY DATE
    var deadlines = [Date: String]() // time: topic
  
    let NoDeadlines = "Дедлайнов нет"
  
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
      let currentDate = Date()
      handler(currentDate)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
      let currentDate = Date()
      let endDate =
        currentDate.addingTimeInterval(TimeInterval(2 * 24 * 60 * 60))
      handler(endDate)
    }
  
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        if complication.family == .modularLarge {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "hh:mm"
          
          var entry: CLKComplicationTimelineEntry!
          if let first = deadlines.keys.first {
            let timeString = dateFormatter.string(from: first)
            entry = createTimeLineEntry(headerText: timeString, bodyText: deadlines[first] ?? NoDeadlines, date: Date())
          } else {
            let timeString = dateFormatter.string(from: Date())
            entry = createTimeLineEntry(headerText: timeString, bodyText: NoDeadlines, date: Date())
          }
          handler(entry)
        } else {
          handler(nil)
        }
    }
  
  func createTimeLineEntry(headerText: String, bodyText: String, date: Date) -> CLKComplicationTimelineEntry {
    
    let template = CLKComplicationTemplateModularLargeStandardBody()
    let clock = UIImage(named: "clock")
    
    template.headerImageProvider =
      CLKImageProvider(onePieceImage: clock!)
    template.headerTextProvider = CLKSimpleTextProvider(text: headerText)
    template.body1TextProvider = CLKSimpleTextProvider(text: bodyText)
    
    let entry = CLKComplicationTimelineEntry(date: date,
                                             complicationTemplate: template)
    
    return(entry)
  }
  
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
      var timeLineEntryArray = [CLKComplicationTimelineEntry]()
      // Right after the first deadline we will show the next one
      for (index, key) in deadlines.keys.enumerated() {
        if index == 0 {
          continue
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        
        let timeString = dateFormatter.string(from: key)
        
        let entry = createTimeLineEntry(headerText: timeString, bodyText: deadlines[key] ?? NoDeadlines, date: key)
        
        timeLineEntryArray.append(entry)
      }
      handler(timeLineEntryArray)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
      let template = CLKComplicationTemplateModularLargeStandardBody()
      let clock = UIImage(named: "clock")
      
      template.headerImageProvider =
        CLKImageProvider(onePieceImage: clock!)
      
      template.headerTextProvider =
        CLKSimpleTextProvider(text: "Курсы Stepic")
      template.body1TextProvider =
        CLKSimpleTextProvider(text: "Расписание дедлайнов")
      
      handler(template)
    }
  
}
