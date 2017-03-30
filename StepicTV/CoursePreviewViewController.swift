//
//  CoursePreviewViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 14/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CoursePreviewViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var textData : [(String, String)] = []
    
    var video: Video!
    
    var sectionTitles = [String]()
    var isErrorWhileLoadingSections : Bool = false
    var isLoadingSections: Bool = false
    
    var course : Course? = nil{
        didSet{
            if let c = course {
                
                if c.summary != "" {
                    textData += [(NSLocalizedString("Summary", comment: ""), c.summary)]
                }
                if c.courseDescription != "" {
                    textData += [(NSLocalizedString("Description", comment: ""), c.courseDescription)]
                }
                if c.workload != "" {
                    textData += [(NSLocalizedString("Workload", comment: ""), c.workload)]
                }
                if c.certificate != "" {
                    textData += [(NSLocalizedString("Certificate", comment: ""), c.certificate)]
                }
                if c.audience != "" {
                    textData += [(NSLocalizedString("Audience", comment: ""), c.audience)]
                }
                if c.format != "" {
                    textData += [(NSLocalizedString("Format", comment: ""), c.format)]
                }
                if c.requirements != "" {
                    textData += [(NSLocalizedString("Requirements", comment: ""), c.requirements)]
                }
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
        tableView.register(UINib(nibName: "TitleTextTableViewCell", bundle: nil), forCellReuseIdentifier: "TitleTextTableViewCell")
        tableView.register(UINib(nibName: "TeachersTableViewCell", bundle: nil), forCellReuseIdentifier: "TeachersTableViewCell")
        tableView.estimatedRowHeight = 300
    }
    
    //MARK: - Enrollment
    
    func askForUnenroll(unenroll: @escaping (Void)->Void) {
        let alert = UIAlertController(title: NSLocalizedString("UnenrollAlertTitle", comment: "") , message: NSLocalizedString("UnenrollAlertMessage", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Unenroll", comment: "") , style: .destructive, handler: {
            action in
            unenroll()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func joinButtonTap(sender:UIButton){
//            if !StepicApplicationsInfo.doesAllowCourseUnenrollment {
//            return
//        }
//        
//        if !AuthInfo.shared.isAuthorized {
//            if let vc = TVControllerHelper.getAuthController(){
//                vc.success = {
//                    [weak self] controller in
//                    if let s = self {
//                        s.joinButtonPressed(sender)
//                    }
//                }
//                self.present(vc, animated: true, completion: nil)
//            }
//            return
//        }
//        
//        //TODO : Add statuses
//        if let c = course {
//            
//            if sender.isEnabledToJoin {
//                AuthManager.sharedManager.joinCourseWithId(c.id, success : {
//                    
//                    sender.isEnabled = true
//                    sender.setDisabledJoined()
//                    self.course?.enrolled = true
//                    CoreDataHelper.instance.save()
//                    CoursesJoinManager.sharedManager.addedCourses += [c]
//                    
//                    self.performSegue(withIdentifier: "showSections", sender: nil)
//                }, error:  {
//                    status in
//                    
//                    
//                })
//            } else {
//                askForUnenroll(unenroll: {
//                    
//                    
//                    AuthManager.sharedManager.joinCourseWithId(c.id, delete: true, success : {
//                        
//                        sender.isEnabled = true
//                        sender.setEnabledJoined()
//                        self.course?.enrolled = false
//                        CoreDataHelper.instance.save()
//                        CoursesJoinManager.sharedManager.deletedCourses += [c]
//                        self.navigationController?.popToRootViewController(animated: true)
//                    }, error:  {
//                        status in
//                    
//                        
//                    })
//                })
//            }
//        }
    }
}

extension CoursePreviewViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool {
        return true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textData.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoursePreviewTableViewCell", for: indexPath) as! CoursePreviewTableViewCell
            cell.initWith(course: course!)
            cell.delegate = self
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeachersTableViewCell", for: indexPath) as! TeachersTableViewCell
            cell.initWithCourse(course!)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TitleTextTableViewCell", for: indexPath) as! TitleTextTableViewCell
        cell.initWith(title: textData[indexPath.row - 2].0, text: textData[indexPath.row - 2].1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0: return "Detailed"
        case 1: return "Detailed"
        case 2: return "Modules"
        default: return nil
        }
    }
}

extension CoursePreviewViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 20
    }
}

extension CoursePreviewViewController : CoursePreviewTableViewCellDelegate{
    func joinButtonTap(in cell: CoursePreviewTableViewCell){
        
    }
    
    func playButtonTap(in cell: CoursePreviewTableViewCell){
        
    }
}
