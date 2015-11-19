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
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithCourse(course: Course) {
//        instructors = course.instructors
        course.loadAllInstructors(success: {
            self.instructors = course.instructors
//            print("instructors count -> \(self.instructors.count)")
            UIThread.performUI({self.collectionView.reloadData()})
        })
//        collectionView.reloadData()
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

extension TeachersTableViewCell : UICollectionViewDelegate {
    
}