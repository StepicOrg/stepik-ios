//
//  LessonTableViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

extension UILabel {

    var textSize: CGSize? {
        guard let labelText = text else {
            return nil
        }

        let labelTextSize = (labelText as NSString).size(withAttributes: [NSAttributedStringKey.font: font])

        return labelTextSize
    }
}

class LessonTableViewCell: FocusableCustomTableViewCell {

    static var reuseIdentifier: String { return "LessonTableViewCell" }
    static var estimatedSize: CGFloat { return CGFloat(90) }

    static func getHeightForCell(with viewData: LessonViewData, width: CGFloat) -> CGFloat {
        return UILabel.heightForLabelWithText(viewData.title, lines: 0, font: UIFont.systemFont(ofSize: 38, weight: .medium), width: width - 370, alignment: .left) + 45
    }

    @IBOutlet var indexLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressIcon: UIImageView!

    @IBOutlet weak var progressLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var indexLabelWidth: NSLayoutConstraint!

    var progress : Float = 0

    private var pressAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        changeToDefault()
    }

    private func setupProgressLayer(forProgress progress: Float, withTintColor tintColor: UIColor = UIColor.black.withAlphaComponent(0.3)) {
        guard let progressIcon = self.progressIcon else {
            return;
        }

        progressIcon.layer.sublayers?.removeAll()

        let ciColor = CIColor(color: tintColor)
        let red = ciColor.red
        let green = ciColor.green
        let blue = ciColor.blue
        let alpha = ciColor.alpha

        let tintColor = UIColor(red: red + 1 - alpha, green: green + 1 - alpha, blue: blue + 1 - alpha, alpha: 1)

        let width = progressIcon.frame.width

        var lineWidth = width / 2
        var circlePath = UIBezierPath(arcCenter: CGPoint(x: width / 2,y: width / 2), radius: CGFloat(lineWidth / 2), startAngle: CGFloat(-Float.pi / 2), endAngle:CGFloat(Float.pi * 2 * progress - Float.pi / 2), clockwise: true)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = tintColor.cgColor
        shapeLayer.lineWidth = lineWidth

        lineWidth = width * 0.1;
        circlePath = UIBezierPath(arcCenter: CGPoint(x: width / 2,y: width / 2), radius: CGFloat(width / 2 - lineWidth / 2), startAngle: CGFloat(-Float.pi / 2), endAngle:CGFloat(Float.pi * 2 - Float.pi / 2), clockwise: true)

        let borderLayer = CAShapeLayer()
        borderLayer.path = circlePath.cgPath
        borderLayer.fillColor = shapeLayer.fillColor
        borderLayer.strokeColor = shapeLayer.strokeColor
        borderLayer.lineWidth = lineWidth

        progressIcon.layer.addSublayer(shapeLayer)
        progressIcon.layer.addSublayer(borderLayer)
    }

    func setup(with paragraphIndex: Int, _ lessonIndex: Int, viewData: LessonViewData) {
        self.indexLabel.text = "\(paragraphIndex).\(lessonIndex)."
        self.nameLabel.text = viewData.title
        self.progressLabel.text = viewData.progressText

        progress = Float(viewData.progress.score) / Float(viewData.progress.cost)
        self.setupProgressLayer(forProgress: progress)

        self.pressAction = viewData.action

        indexLabelWidth.constant = (indexLabel.textSize?.width ?? 0) + CGFloat(1)
        progressLabelWidth.constant = (progressLabel.textSize?.width ?? 0) + CGFloat(1)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)

        guard presses.first!.type != UIPressType.menu else { return }
        pressAction?()
    }

    override func changeToDefault() {
        super.changeToDefault()

        let color = UIColor.black.withAlphaComponent(0.3)
        setTint(color: color)
    }

    override func changeToFocused() {
        super.changeToFocused()

        let color = UIColor.white
        setTint(color: color)
    }

    private func setTint(color: UIColor) {
        indexLabel?.textColor = color
        nameLabel?.textColor = color
        progressLabel?.textColor = color
        progressIcon?.tintColor = color
        self.setupProgressLayer(forProgress: progress, withTintColor: color)
    }
}
