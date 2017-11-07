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
    case Video
    case Text
    case Task

    var icon: UIImage {
        switch self {
        case .Video: return UIImage(named: "video_icon.pdf")!
        case .Text: return UIImage(named: "text_icon.pdf")!
        case .Task: return UIImage(named: "task_icon.pdf")!
        }
    }
}

protocol LessonPartPresentContentDelegate: class {
    func loadContentIn(controller: UIViewController, completion: @escaping () -> Void)
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
        default:
            loadVideoTask()
        }
    }

    func loadVideoTask() {
        // Create an AVAsset with for the media's URL.
        let mediaURL = URL(string: "https://youtu.be/Lyxv0z4OcmI")!
        let asset = AVAsset(url: mediaURL)
        let playerItem = AVPlayerItem(asset: asset)

        // Create and present an `AVPlayerViewController`.
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(playerItem: playerItem)
        playerViewController.player = player

        self.delegate?.loadContentIn(controller: playerViewController, completion: { player.play() })
    }

}
