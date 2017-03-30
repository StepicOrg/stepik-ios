//
//  StepsViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 25/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

enum StepsControllerPresentationContext {
    case lesson, unit
}

class StepsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stepsBarCollectionView: UICollectionView!
    var lesson: Lesson!
    var startStepId : Int = 0
    var didSelectTab = false
    
    
    //By default presentation context is unit
    var context : StepsControllerPresentationContext = .unit
    
    lazy var activityView : UIView = self.initActivityView()
    lazy var warningView : UIView = self.initWarningView()
    let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")
    
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let l = lesson {
            if !didSelectTab && l.steps.count != 0  && startStepId < l.steps.count {
                print("\nselected tab for step with id -> \(startStepId)\n")
                didSelectTab = true
                self.selectTab(at: startStepId, update: true)
                return
            }
        }
        
        if lesson.steps.count > 0 {
            self.selectTab(at: 0, update: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepsBarCollectionView.delegate = self
        stepsBarCollectionView.dataSource = self
        
        stepsBarCollectionView.register(UINib(nibName:StepTabCollectionViewCell.nibName, bundle: nil), forCellWithReuseIdentifier: StepTabCollectionViewCell.reuseIdentifier)
        
        refreshSteps()
    }
    
    //MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lesson.steps.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StepTabCollectionViewCell.reuseIdentifier, for: indexPath) as! StepTabCollectionViewCell
        
        let step = lesson.steps[indexPath.row]
        cell.stepImage.image = step.block.image
        cell.stepCompleteImage.isHidden = !(step.progress?.isPassed ?? false)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let videoController = childViewControllers.first as? VideoStepViewController {
            videoController.playVideo()
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        
        guard let indexPath = context.nextFocusedIndexPath else { return false }
        let step = lesson.steps[indexPath.row]
        
        if step.block.type == .Video {
            let videoStepVC = VideoStepViewController()
            videoStepVC.video = step.block.video!
            activeViewController = videoStepVC
        } else {
            activeViewController = QuizStepViewController()
        }
        
        return true
    }
    
    //MARK: - Tabs
    
    
    private var activeViewController: UIViewController? {
        didSet {
            removeInactiveViewController(oldValue)
            updateActiveViewController()
        }
    }
    
    private func removeInactiveViewController(_ inactiveViewController: UIViewController?) {
        if let inActiveVC = inactiveViewController {
            // call before removing child view controller's view from hierarchy
            inActiveVC.willMove(toParentViewController: nil)
            
            inActiveVC.view.removeFromSuperview()
            
            // call after removing child view controller's view from hierarchy
            inActiveVC.removeFromParentViewController()
        }
    }
    
    private func updateActiveViewController() {
        if let activeVC = activeViewController {
            // call before adding child view controller's view as subview
            addChildViewController(activeVC)
            
            activeVC.view.frame = containerView.bounds
            containerView.addSubview(activeVC.view)
            
            // call before adding child view controller's view as subview
            activeVC.didMove(toParentViewController: self)
        }
    }
    
    //MARK: - Custom methods
    
    func initWarningView() -> UIView {
        return UIView()
    }
    
    func initActivityView() -> UIView {
        return UIView()
    }
    
    var doesPresentActivityIndicatorView : Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                DispatchQueue.main.async{
                    [weak self] in
                    self?.activityView.isHidden = false
                }
            } else {
                DispatchQueue.main.async{
                    [weak self] in
                    self?.activityView.isHidden = true
                }
            }
        }
    }
    
    var doesPresentWarningView : Bool = false {
        didSet {
            if doesPresentWarningView {
                DispatchQueue.main.async{
                    [weak self] in
                    self?.warningView.isHidden = false
                }
            } else {
                DispatchQueue.main.async{
                    [weak self] in
                    self?.warningView.isHidden = true
                }
            }
        }
    }
    
    
    fileprivate func refreshSteps() {
        var prevStepsIds = [Int]()
        if lesson.steps.count == 0 {
            self.view.isUserInteractionEnabled = false
            self.doesPresentWarningView = false
            self.doesPresentActivityIndicatorView = true
        } else {
            if let l = lesson {
                prevStepsIds = l.stepsArray
            }
        }
        
        
        lesson?.loadSteps(completion: {
            [weak self] in
            if let s = self {
                let newStepsSet = Set(s.lesson!.stepsArray)
                let prevStepsSet = Set(prevStepsIds)
                
                var reloadBlock : ((Void)->Void) = {
                    [weak self] in
                    self?.reloadData()
                }
                
                if newStepsSet.symmetricDifference(prevStepsSet).count == 0 {
                    //need to reload one by one
                    reloadBlock = {
                        print("did send step updated notification")
                        //update tab views
                        for index in 0 ..< s.lesson!.steps.count {
                            //                            let tabView = s.pageViewController(s, tabViewForPageAt: index) as? StepTabView
                            //                            if let progress = s.lesson!.steps[index].progress {
                            //                                tabView?.setTab(selected: progress.isPassed, animated: true)
                            //                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    [weak self] in
                    s.view.isUserInteractionEnabled = true
                    reloadBlock()
                    s.doesPresentWarningView = false
                    s.doesPresentActivityIndicatorView = false
                    
                    if s.startStepId < s.lesson!.steps.count {
                        if !s.didSelectTab {
                            s.selectTab(at: s.startStepId, update: true)
                            s.didSelectTab = true
                        }
                    }
                }
            }
            }, error: {
                errorText in
                print("error while loading steps in stepsviewcontroller")
        }, onlyLesson: context == .lesson)
    }
    
    func reloadData(){
        stepsBarCollectionView.reloadData()
    }
    
    func selectTab(at index:Int, update: Bool){
        stepsBarCollectionView.selectItem(at: IndexPath.init(row: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
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
