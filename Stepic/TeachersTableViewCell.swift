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
    
    var instructors : [User] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView?.registerNib(UINib(nibName: "TeacherCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TeacherCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TeachersTableViewCell.didRotate), name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithCourse(course: Course) {
        //TODO: JUST REMOVE THIS AT SOME TIME
//        instructors = course.instructors
        if AuthInfo.shared.isAuthorized {
        course.loadAllInstructors(success: {
            self.instructors = course.instructors
            UIThread.performUI({self.collectionView.reloadData()})
        })
        } else {
            course.loadInstructorsWithoutAuth(success: {
                self.instructors = course.instructors
                UIThread.performUI({self.collectionView.reloadData()})
            })
        }
//        collectionView.reloadData()
    }
    
    func didRotate() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension TeachersTableViewCell : UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instructors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TeacherCollectionViewCell", forIndexPath: indexPath) as! TeacherCollectionViewCell
        cell.initWithUser(instructors[indexPath.item])
        return cell
    }
    
}

extension TeachersTableViewCell : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let usedWidth : CGFloat = CGFloat(instructors.count) * 120 + CGFloat(instructors.count - 1) * 10
        let edgeInsets = max((collectionView.frame.size.width - usedWidth) / 2, 0)
        
        return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets)
    }
}


extension TeachersTableViewCell : UICollectionViewDelegate {
    
}