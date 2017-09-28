//
//  CourseWidgetView.swift
//  Stepic
//
//  Created by Ostrenkiy on 27.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

@IBDesignable
class CourseWidgetView: NibInitializableView {

    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var courseTitleLabel: StepikLabel!
    @IBOutlet weak var courseStatsCollectionView: UICollectionView!
    @IBOutlet weak var actionButton: StepikButton!

    @IBOutlet weak var courseStatsCollectionViewFlowLayout: UICollectionViewFlowLayout!

    enum ButtonState {
        case join, continueLearning
    }
    
    var action: (() -> Void)?

    fileprivate var stats: [CourseStatData] = []

    override var nibName: String {
        return "CourseWidgetView"
    }

    @IBInspectable
    var title: String? {
        didSet {
            courseTitleLabel.text = title
        }
    }

    var imageURL: URL? {
        didSet {
            courseImageView.setImageWithURL(url: imageURL, placeholder: #imageLiteral(resourceName: "stepic_logo_black_and_white"))
        }
    }

    var rating: Float? {
        didSet {
            updateStats()
        }
    }

    var learners: Int? {
        didSet {
            updateStats()
        }
    }

    var progress: Float? {
        didSet {
            updateStats()
        }
    }

    var buttonState: ButtonState = .continueLearning {
        didSet {
            switch buttonState {
            case .join:
                actionButton.isGray = true
                actionButton.setTitle(NSLocalizedString("AboutCourse", comment: ""), for: .normal)
                break
            case .continueLearning:
                actionButton.isGray = false
                actionButton.setTitle(NSLocalizedString("ContinueLearning", comment: ""), for: .normal)
                break
            }
        }
    }

    private func updateStats() {
        var newStats: [CourseStatData] = []
        if let rating = rating {
            newStats += [CourseStatData(image: #imageLiteral(resourceName: "tab-profile"), text: String(format: "%.1f", rating))]
        }
        if let learners = learners {
            newStats += [CourseStatData(image: #imageLiteral(resourceName: "tab-profile"), text: "\(learners)")]
        }
        if let progress = progress {
            newStats += [CourseStatData(image: #imageLiteral(resourceName: "tab-profile"), text: "\(Int(progress.rounded(.toNearestOrAwayFromZero)))%")]
        }
        self.stats = newStats
        courseStatsCollectionView.reloadData()
    }

    override func setupSubviews() {
        courseImageView.setRoundedCorners(cornerRadius: 8)
        self.courseStatsCollectionView.register(UINib(nibName: "CourseStatCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseStatCollectionViewCell")
        courseStatsCollectionView.delegate = self
        courseStatsCollectionView.dataSource = self
        courseStatsCollectionViewFlowLayout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
        courseStatsCollectionViewFlowLayout.minimumInteritemSpacing = 8
        courseStatsCollectionViewFlowLayout.minimumLineSpacing = 8
    }

    @IBAction func actionButtonPressed(_ sender: Any) {
        action?()
    }

}

extension CourseWidgetView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension CourseWidgetView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stats.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = courseStatsCollectionView.dequeueReusableCell(withReuseIdentifier: "CourseStatCollectionViewCell", for: indexPath) as! CourseStatCollectionViewCell
        cell.setup(data: stats[indexPath.item])
        return cell
    }
}

struct CourseStatData {
    var image: UIImage
    var text: String

    init(image: UIImage, text: String) {
        self.image = image
        self.text = text
    }
}
