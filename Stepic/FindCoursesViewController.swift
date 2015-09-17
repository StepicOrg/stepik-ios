//
//  FindCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class FindCoursesViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "CourseTableViewCell", bundle: nil), forCellReuseIdentifier: "CourseTableViewCell")
        
        ApiDataDownloader.sharedDownloader.getCoursesWith(true, page: nil, success: {
            (courses, _) in
            self.courses = courses
            self.tableView.reloadData()
        }, failure: {
            error in 
            println(error.localizedDescription)
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    var courses : [Course] = []
}


extension FindCoursesViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}

extension FindCoursesViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CourseTableViewCell", forIndexPath: indexPath) as! CourseTableViewCell
        
        cell.initWithCourse(courses[indexPath.row])
        
        return cell
    }
}