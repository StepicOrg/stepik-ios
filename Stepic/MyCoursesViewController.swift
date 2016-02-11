//
//  MyCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class MyCoursesViewController: CoursesViewController {
    
    override var tabIds :  [Int] {
        get {
            return TabsInfo.myCoursesIds
        }
        
        set(value) {
            TabsInfo.myCoursesIds = value
        }
    }
    
    override func viewDidLoad() {
        loadEnrolled = true
        loadFeatured = nil
        
        super.viewDidLoad()
    }
}

extension MyCoursesViewController {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        switch emptyDatasetState {
        case .Empty:
            return Images.emptyCoursesPlaceholder
        case .ConnectionError:
            return Images.noWifiImage.size250x250
        }
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .Empty:
            text = NSLocalizedString("EmptyMyCoursesTitle", comment: "")
            break
        case .ConnectionError:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
            break
        }
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0),
            NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        
        switch emptyDatasetState {
        case .Empty:
            text = NSLocalizedString("EmptyMyCoursesDescription", comment: "")
            break
        case .ConnectionError:
            text = NSLocalizedString("ConnectionErrorPullToRefresh", comment: "")
            break
        }
                
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
//        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 44
    }
}

extension MyCoursesViewController  {
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}