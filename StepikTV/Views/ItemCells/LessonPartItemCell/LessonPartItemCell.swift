//
//  LessonPartItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import AVKit

enum LessonsPartContentType {
    case Video, Text, Task

    enum TaskType {
        case Choice, Text
    }

    var icon: UIImage {
        switch self {
        case .Video: return UIImage(named: "video_icon.pdf")!
        case .Text: return UIImage(named: "text_icon.pdf")!
        case .Task: return UIImage(named: "task_icon.pdf")!
        }
    }
}

protocol LessonPartPresentContentDelegate: class {
    func loadLessonContent(with controller: UIViewController, completion: @escaping () -> Void)
}

class LessonPartItemCell: UICollectionViewCell {

    static var nibName: String { get { return "LessonPartItemCell" } }

    static var reuseIdentifier: String { get { return "LessonPartItemCell" } }

    static var size: CGSize { get { return CGSize(width: 548, height: 606) } }

    @IBOutlet var cardView: UIView!

    @IBOutlet var iconImageView: UIImageView!

    @IBOutlet var bottomDieView: UIView!

    @IBOutlet var indexLabel: UILabel!

    weak var delegate: LessonPartPresentContentDelegate?

    var contentType: LessonsPartContentType?

    var taskType: LessonsPartContentType.TaskType?

    var video : Video?

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        return [cardView]
    }

    func configure(with data: LessonPart, index: Int) {
        contentType = data.type

        indexLabel.text = "\(index)"
        iconImageView.image = data.type.icon
        bottomDieView.isHidden = !data.isDone
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)

        switch contentType {
        case .Task?:
            loadTask(taskType!)
        default:
            loadVideo()
        }
    }

    func loadTask(_ type: LessonsPartContentType.TaskType) {
        let task = LessonContentAlertController(title: "", message: "", preferredStyle: .alert)

        switch type {
        case .Text:
            task.generateTextTaskContent(question: "Рядом с каждым тестом и задачей указано количество баллов, которое вы получите за правильное решение. Ваш общий прогресс также отображается в оглавлении курса, там же видны и сроки сдачи каждой из задач.")
        case .Choice:
            task.generateChoiceTaskContent(question: "Кто вы по профессии?", choices: ["Школьник", "Студент", "Учитель", "Программист"])
        }

        self.delegate?.loadLessonContent(with: task, completion: {})
    }

    func loadVideo() {
        guard let video = video else { return }

        /*
        if video.state == VideoState.cached || (ConnectionHelper.shared.reachability.isReachableViaWiFi() || ConnectionHelper.shared.reachability.isReachableViaWWAN()) {
            ///Present player
            let player = TVPlayerViewController()
            self.delegate?.loadLessonContent(with: player, completion: { player.playVideo(url: video.getUrlForQuality("480")) })
        }*/
    }

}

class TVPlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {

    func playVideo(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
    }

}
