//
//  FillBlanksQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 11.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

class FillBlanksQuizViewController: QuizViewController {

    var tableView = FullHeightTableView()

    var dataset: FillBlanksDataset?
    var reply: FillBlanksReply?

    var cellWidth: CGFloat {
        if #available(iOS 11.0, *) {
            return tableView.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        } else {
            return tableView.bounds.width
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        self.containerView.addSubview(tableView)
        tableView.align(toView: self.containerView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

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
        guard let dataset = dataset else {
            return nil
        }

        guard index < dataset.components.count else {
            return nil
        }

        return answerForComponent[index] ?? ""
    }

    override func getReply() -> Reply? {
        guard let dataset = dataset else {
            return FillBlanksReply(blanks: [])
        }

        var blanks: [String] = []

        for (index, component) in dataset.components.enumerated() {
            if component.type != .text {
                if let ans = getAnswerForComponent(atIndex: index) {
                    blanks += [ans]
                }
            }
        }

        return FillBlanksReply(blanks: blanks)
    }

    let fillBlanksPickerPresenter: Presentr = {
        let fillBlanksPickerPresenter = Presentr(presentationType: .bottomHalf)
        return fillBlanksPickerPresenter
    }()

    func presentPicker(data: [String], selectedBlock: @escaping (String) -> Void) {
        let vc = PickerViewController(nibName: "PickerViewController", bundle: nil)
        vc.data = data
        vc.pickerTitle = NSLocalizedString("FillBlankOptionTitle", comment: "")
        vc.selectedBlock = {
            [weak self] in
            selectedBlock(vc.selectedData)
            self?.tableView.reloadData()
        }
        customPresentViewController(fillBlanksPickerPresenter, viewController: vc, animated: true, completion: nil)
    }

    func heightForComponentRow(index: Int) -> CGFloat {
        guard let dataset = dataset else {
            return 0
        }

        guard index < dataset.components.count else {
            return 0
        }

        switch dataset.components[index].type {
        case .input :
            return FillBlanksInputTableViewCell.defaultHeight
        case .text:
            return FillBlanksTextTableViewCell.getHeight(htmlText: dataset.components[index].text, width: cellWidth)
        case .select:
            if let ans = getAnswerForComponent(atIndex: index) {
                return FillBlanksChoiceTableViewCell.getHeight(text: ans, width: cellWidth)
            } else {
                return 0
            }
        }
    }

    var answerForComponent: [Int: String] = [:]

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? FillBlanksDataset else {
            return
        }

        self.dataset = dataset

        self.tableView.isUserInteractionEnabled = true
        answerForComponent = [:]
        self.tableView.reloadData()
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? FillBlanksReply else {
            return
        }

        self.reply = reply
        display(reply: reply)
        self.tableView.isUserInteractionEnabled = false
    }

    override func display(reply: Reply) {
        guard let reply = reply as? FillBlanksReply else {
            return
        }

        guard let dataset = dataset else {
            return
        }

        var activeComponentIndex = 0
        for (index, component) in dataset.components.enumerated() {
            if component.type != .text {
                answerForComponent[index] = reply.blanks[activeComponentIndex]
                activeComponentIndex += 1
            }
        }

        self.tableView.reloadData()
    }
}

extension FillBlanksQuizViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("height for row at indexPath \(indexPath.row)")
        return heightForComponentRow(index: indexPath.row)
    }

}

extension FillBlanksQuizViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell for row at indexPath \(indexPath.row)")
        guard let dataset = dataset else {
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
            if let ans = answerForComponent[indexPath.row] {
                cell.answer = ans
            } else {
                cell.answer = ""
            }
            cell.answerDidChange = {
                [weak self]
                answer in
                self?.answerForComponent[indexPath.row] = answer
            }
            return cell
        case .select:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FillBlanksChoiceTableViewCell", for: indexPath) as! FillBlanksChoiceTableViewCell
            if let ans = answerForComponent[indexPath.row] {
                cell.setOption(text: ans)
            } else {
                cell.setOption(text: nil)
            }
            cell.selectedAction = {
                [weak self] in
                self?.presentPicker(data: component.options, selectedBlock: {
                    [weak self]
                    selectedOption in
                    self?.answerForComponent[indexPath.row] = selectedOption
                    self?.tableView.reloadData()
                })
            }
            return cell
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataset != nil ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataset = dataset else {
            return 0
        }

        return dataset.components.count
    }

}
