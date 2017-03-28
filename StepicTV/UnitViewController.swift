//
//  UnitViewController.swift
//  Stepic
//
//  Created by Anton Kondrashov on 24/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class UnitsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var section : Section!
    var didRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: "UnitTableViewCell", bundle: nil), forCellReuseIdentifier: "UnitTableViewCell")
        
        refreshUnits()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        section.loadProgressesForUnits(units: section.units, completion: {
            UIThread.performUI({
                self.tableView.reloadData()
            })
        })
    }
    
    func refreshUnits() {
        didRefresh = false
        section.loadUnits(success: {
            UIThread.performUI({
                self.tableView.reloadData()
            })
            self.didRefresh = true
        }, error: {
            self.didRefresh = true
        })
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSteps", let dest = segue.destination as? StepsViewController {
            if let stepsPresentation = sender as? StepsPresentation {
                let index = stepsPresentation.index
                dest.lesson = section.units[index].lesson
            }
        }
    }
    
    var currentlyDisplayingUnitIndex: Int?
    
    func selectUnitAtIndex(_ index: Int, isLastStep: Bool = false, replace: Bool = false) {
        performSegue(withIdentifier: replace ? "replaceSteps" : "showSteps", sender: StepsPresentation(index: index, isLastStep: isLastStep))
    }
    
    func clearAllSelection() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for indexPath in selectedRows {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
}

class StepsPresentation {
    var index: Int
    var isLastStep: Bool
    init(index: Int, isLastStep: Bool) {
        self.index = index
        self.isLastStep = isLastStep
    }
}

extension UnitsViewController : SectionNavigationDelegate {
    func displayNext() {
        if let uIndex = currentlyDisplayingUnitIndex {
            if uIndex + 1 < section.units.count {
                selectUnitAtIndex(uIndex + 1, replace: true)
            }
        }
    }
    
    func displayPrev() {
        if let uIndex = currentlyDisplayingUnitIndex {
            if uIndex - 1 >= 0 {
                selectUnitAtIndex(uIndex - 1, isLastStep: true, replace: true)
            }
        }
    }
}

extension UnitsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectUnitAtIndex((indexPath as NSIndexPath).row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UnitTableViewCell.heightForCellWithUnit(self.section.units[(indexPath as NSIndexPath).row])
    }
    
}

extension UnitsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section.units.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UnitTableViewCell", for: indexPath) as! UnitTableViewCell
        
        cell.initWithUnit(self.section.units[indexPath.row])
        
        return cell
    }
}
