//
//  FillBlanksQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class FillBlanksQuizViewController: QuizViewController {

    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        self.containerView.addSubview(tableView)
        tableView.align(to: self.containerView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "FillBlanksChoiceTableViewCell", bundle: nil), forCellReuseIdentifier: "FillBlanksChoiceTableViewCell")
        tableView.register(UINib(nibName: "FillBlanksTextTableViewCell", bundle: nil), forCellReuseIdentifier: "FillBlanksTextTableViewCell")
        tableView.register(UINib(nibName: "FillBlanksInputTableViewCell", bundle: nil), forCellReuseIdentifier: "FillBlanksInputTableViewCell")

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func getAnswerForComponent(atIndex index: Int) -> String? {
        guard let dataset = attempt?.dataset as? FillBlanksDataset else {
            return nil
        }
        
        guard index < dataset.components.count else {
            return nil
        }
        
        if let p = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? FillBlanksActiveTableViewCellProtocol {
            return p.result
        } else {
            return nil
        }
        
    }
    
    override func getReply() -> Reply {
        guard let dataset = attempt?.dataset as? FillBlanksDataset else {
            return FillBlanksReply(blanks: [])
        }
        
        var blanks : [String] = []
        
        for (index, component) in dataset.components.enumerated() {
            if component.type != .text {
                if let ans = getAnswerForComponent(atIndex: index) {
                    blanks += [ans]
                }
            }
        }
        
        return FillBlanksReply(blanks: blanks)
    }
}

extension FillBlanksQuizViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataset = attempt?.dataset as? FillBlanksDataset else {
            return 0
        }
        
        guard indexPath.row < dataset.components.count else {
            return 0
        }
        
        switch dataset.components[indexPath.row].type {
        case .input :
            return FillBlanksInputTableViewCell.defaultHeight
        case .text:
            return FillBlanksTextTableViewCell.getHeight(htmlText: dataset.components[indexPath.row].text, width: self.view.bounds.width)
        case .select:
            if let ans = getAnswerForComponent(atIndex: indexPath.row) {
                return FillBlanksChoiceTableViewCell.getHeight(text: ans, width: self.view.bounds.width)
            } else {
                return 0
            }
        }
    }
    
}

extension FillBlanksQuizViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataset = attempt?.dataset as? FillBlanksDataset else {
            return UITableViewCell()
        }
        
        guard indexPath.row < dataset.components.count else {
            return UITableViewCell()
        }
        
        let component = dataset.components[indexPath.row]
        
        switch component.type {
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FillBlanksTextTableViewCell", for: indexPath) as! FillBlanksTextTableViewCell
            cell.setHTMLText(component.text)
            return cell 
        case .input:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FillBlanksInputTableViewCell", for: indexPath) as! FillBlanksInputTableViewCell
            return cell
        case .select:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FillBlanksChoiceTableViewCell", for: indexPath) as! FillBlanksChoiceTableViewCell
            cell.selectedAction = {
                [weak self] in
                
            }
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if attempt != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataset = attempt?.dataset as? FillBlanksDataset else {
            return 0
        }
        
        return dataset.components.count
    }
    
    
    
}
