//
//  StepsViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 25/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class StepsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var stepsBarCollectionView: UICollectionView!
    var lesson: Lesson!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepsBarCollectionView.delegate = self
        stepsBarCollectionView.dataSource = self
        
        stepsBarCollectionView.register(UINib(nibName:StepTabCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: StepTabCollectionViewCell.reuseIdentifier)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lesson.steps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StepTabCollectionViewCell.reuseIdentifier, for: indexPath) as! StepTabCollectionViewCell
        
        let step = lesson.steps[indexPath.row]
        cell.stepImage.image = step.block.image
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
