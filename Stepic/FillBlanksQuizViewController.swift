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

    func getAnswerForComponent(atIndex: Int) -> String {
        guard let dataset = attempt?.dataset as? FillBlanksDataset else {
            return ""
        }
        
        guard index < dataset.components.count else {
            return ""
        }
        
        
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
            return FillBlanksChoiceTableViewCell.getHeight(text: getAnswerForComponent(atIndex: indexPath.row), width: self.view.bounds.width)
        }
    }
    
}

extension FillBlanksQuizViewController : UITableViewDataSource {
    
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
