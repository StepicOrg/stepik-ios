//
//  SectionsViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 24/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SectionsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var didRefresh = false
    var course : Course!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "SectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionTableViewCell")
        
        refreshSections()
        
        // Do any additional setup after loading the view.
    }
    
    var url : String {
        if let slug = course?.slug {
            return StepicApplicationsInfo.stepicURL + "/course/" + slug + "/syllabus/"
        } else {
            return ""
        }
    }
    
    func infoButtonPressed(_ button: UIButton) {
        self.performSegue(withIdentifier: "showCourse", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func refreshSections() {
        didRefresh = false
        course.loadAllSections(success: {
            UIThread.performUI({
                self.tableView.reloadData()
            })
            self.didRefresh = true
        }, error: {
            //TODO: Handle error type in section downloading
            UIThread.performUI({
                self.tableView.reloadData()
            })
            self.didRefresh = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCourse" {
            let dvc = segue.destination as! CoursePreviewViewController
            dvc.course = course
        }
        if segue.identifier == "showUnits" {
            let dvc = segue.destination as! UnitsViewController
            dvc.section = course.sections[sender as! Int]
        }
    }
}

extension SectionsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = course.sections[indexPath.row]
        if section.isExam {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        performSegue(withIdentifier: "showUnits", sender: (indexPath as NSIndexPath).row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return course.sections[(indexPath as NSIndexPath).row].isActive || (course.sections[(indexPath as NSIndexPath).row].testSectionAction != nil)
    }
    
}

extension SectionsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return course.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTableViewCell", for: indexPath) as! SectionTableViewCell
        
        cell.initWithSection(course.sections[indexPath.row])
        
        return cell
    }
}

