//
//  TeachersTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class TeachersTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var teachersTitleLabel: StepikLabel!

    var instructors: [User] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView?.register(UINib(nibName: "TeacherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TeacherCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self

        teachersTitleLabel.text = NSLocalizedString("Teachers", comment: "")

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(TeachersTableViewCell.didRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithCourse(_ course: Course) {
        //TODO: JUST REMOVE THIS AT SOME TIME
//        instructors = course.instructors
//        if AuthInfo.shared.isAuthorized {
        course.loadAllInstructors(success: {
            self.instructors = course.instructors
            UIThread.performUI({self.collectionView.reloadData()})
        })
//        } else {
//            course.loadInstructorsWithoutAuth(success: {
//                self.instructors = course.instructors
//                UIThread.performUI({self.collectionView.reloadData()})
//            })
//        }
//        collectionView.reloadData()
    }

    func didRotate() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension TeachersTableViewCell : UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instructors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TeacherCollectionViewCell", for: indexPath) as! TeacherCollectionViewCell
        cell.initWithUser(instructors[(indexPath as NSIndexPath).item])
        return cell
    }

}

extension TeachersTableViewCell : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let usedWidth: CGFloat = CGFloat(instructors.count) * 120 + CGFloat(instructors.count - 1) * 10
        let edgeInsets = max((collectionView.frame.size.width - usedWidth) / 2, 0)

        return UIEdgeInsets(top: 0, left: edgeInsets, bottom: 0, right: edgeInsets)
    }
}

extension TeachersTableViewCell : UICollectionViewDelegate {

}
