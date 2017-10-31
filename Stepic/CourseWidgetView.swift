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

    @IBOutlet weak var loadingWidgetView: LoadingCourseWidgetView!

    enum ButtonState {
        case join, continueLearning
    }

    var action: (() -> Void)?
    var colorMode: CourseListColorMode = .light {
        didSet {
            switch colorMode {
            case .dark:
                courseTitleLabel.colorMode = .light
                actionButton.isLightBackground = false
            case .light:
                courseTitleLabel.colorMode = .dark
                actionButton.isLightBackground = true
            }
            updateStats()
        }
    }

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
            courseImageView.setImageWithURL(url: imageURL, placeholder: Images.lessonPlaceholderImage.size50x50)
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

    func setElements(hidden: Bool) {
        courseImageView.isHidden = hidden
        courseTitleLabel.isHidden = hidden
        courseStatsCollectionView.isHidden = hidden
        actionButton.isHidden = hidden
    }

    var isLoading: Bool = false {
        didSet {
            loadingWidgetView.isHidden = !isLoading
            setElements(hidden: isLoading)
            if isLoading {
                loadingWidgetView.animateGradient()
            }
        }
    }

    var buttonState: ButtonState = .continueLearning {
        didSet {
            switch buttonState {
            case .join:
                actionButton.isGray = false
                actionButton.setTitle(NSLocalizedString("AboutCourse", comment: ""), for: .normal)
                break
            case .continueLearning:
                actionButton.isGray = true
                actionButton.setTitle(NSLocalizedString("ContinueLearning", comment: ""), for: .normal)
                break
            }
        }
    }

    private func getCircleLayer(color: UIColor, progress: Float, inRect rect: CGRect) -> CAShapeLayer {
        let circle = CAShapeLayer()
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = color.cgColor
        circle.lineWidth = 2.5
        circle.strokeEnd = CGFloat(progress / 100)
        circle.lineJoin = kCALineJoinRound
        circle.path = UIBezierPath(arcCenter: CGPoint(x: 5, y: 5), radius: 3.5, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true).cgPath
        return circle
    }

    private func getProgressImage(progress: Float, colorMode: CourseListColorMode) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 10, height: 10)
        let progressView = UIView(frame: rect)
        progressView.backgroundColor = UIColor.clear
        let circle = getCircleLayer(color: colorMode == .light ? UIColor.mainDark : UIColor.white, progress: 100, inRect: rect)
        let progressCircle = getCircleLayer(color: UIColor.stepicGreen, progress: progress, inRect: rect)
        progressView.layer.insertSublayer(circle, at: 1)
        progressView.layer.insertSublayer(progressCircle, at: 2)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 10, height: 10), false, 0.0)
        progressView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? #imageLiteral(resourceName: "progress_widget_icon_gray")
    }

    private func updateStats() {
        var newStats: [CourseStatData] = []
        if let learners = learners {
            if learners > 0 {
                newStats += [CourseStatData(image: colorMode == .light ? #imageLiteral(resourceName: "learners_widget_icon_dark") : #imageLiteral(resourceName: "learners_widget_icon_light"), text: "\(learners)", colorMode: colorMode)]
            }
        }
        if let rating = rating {
            if rating > 0 {
                newStats += [CourseStatData(image: colorMode == .light ? #imageLiteral(resourceName: "rating_widget_icon_dark") : #imageLiteral(resourceName: "rating_widget_icon_light"), text: String(format: "%.1f", rating), colorMode: colorMode)]
            }
        }
        if let progress = progress {
            newStats += [CourseStatData(image: getProgressImage(progress: progress, colorMode: colorMode), text: "\(Int(progress.rounded(.toNearestOrAwayFromZero))) %", colorMode: colorMode)]
        }
        self.stats = newStats
        courseStatsCollectionView.reloadData()
    }

    override func setupSubviews() {
        courseImageView.setRoundedCorners(cornerRadius: 8)
        courseImageView.backgroundColor = UIColor.white
        self.courseStatsCollectionView.register(UINib(nibName: "CourseStatCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseStatCollectionViewCell")
        courseStatsCollectionView.delegate = self
        courseStatsCollectionView.dataSource = self
        courseStatsCollectionViewFlowLayout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
        courseStatsCollectionViewFlowLayout.minimumInteritemSpacing = 8
        courseStatsCollectionViewFlowLayout.minimumLineSpacing = 8
        view.backgroundColor = UIColor.clear
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
    var colorMode: CourseListColorMode

    init(image: UIImage, text: String, colorMode: CourseListColorMode) {
        self.image = image
        self.text = text
        self.colorMode = colorMode
    }
}
