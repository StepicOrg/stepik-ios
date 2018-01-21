//
//  LessonPartItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class StepItemCell: UICollectionViewCell {

    static var nibName: String { get { return "StepItemCell" } }
    static var reuseIdentifier: String { get { return "StepItemCell" } }
    static var size: CGSize { get { return CGSize(width: 548, height: 606) } }

    @IBOutlet var cardView: UIView!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var bottomDieView: UIView!
    @IBOutlet var indexLabel: UILabel!

    private var pressAction: (() -> Void)?

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [cardView]
    }

    func setup(with data: StepViewData, index: Int) {
        indexLabel.text = "\(index)"
        iconImageView.image = data.icon
        bottomDieView.isHidden = !data.isPassed!
        pressAction = data.action
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)

        guard presses.first!.type != UIPressType.menu else { return }
        pressAction?()
    }

    /*
    func loadTask(_ type: LessonsPartContentType.TaskType) {
        let task = LessonContentAlertController(title: "", message: "", preferredStyle: .alert)

        switch type {
        case .Text:
            task.generateTextTaskContent(question: "Рядом с каждым тестом и задачей указано количество баллов, которое вы получите за правильное решение. Ваш общий прогресс также отображается в оглавлении курса, там же видны и сроки сдачи каждой из задач.")
        case .Choice:
            task.generateChoiceTaskContent(question: "Кто вы по профессии?", choices: ["Школьник", "Студент", "Учитель", "Программист"])
        }

        //self.delegate?.loadLessonContent(with: task, completion: {})
    } */

}
