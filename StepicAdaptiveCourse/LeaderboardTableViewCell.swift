//
//  LeaderboardTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    enum CellPosition {
        case top, middle, bottom
    }

    static let reuseId = "LeaderboardTableViewCell"

    @IBOutlet weak var cardPadView: UIView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var medalImageView: UIImageView!
    @IBOutlet weak var positionLabel: UILabel!

    private let meColor = UIColor(hex: 0xFFCC66)
    @IBOutlet weak var shadowPadView: UIView!

    var cellPosition: CellPosition = .middle

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        positionLabel.isHidden = true
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        drawRoundCorners()
        drawShadow()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        cardPadView.backgroundColor = .white
        positionLabel.isHidden = true
        cellPosition = .middle
        shadowPadView.layer.shadowPath = nil
    }

    func updateInfo(position: Int, username: String, exp: Int, isMe: Bool = false) {
        updatePosition(position)
        userLabel.text = "\(username)"
        expLabel.text = "\(exp)"

        if isMe {
            cardPadView.backgroundColor = meColor
            userLabel.text = "Вы"
        }
    }

    fileprivate func updatePosition(_ position: Int) {
        medalImageView.isHidden = false
        switch position {
        case 1:
            medalImageView.image = #imageLiteral(resourceName: "medal1")
            break
        case 2:
            medalImageView.image = #imageLiteral(resourceName: "medal2")
            break
        case 3:
            medalImageView.image = #imageLiteral(resourceName: "medal3")
            break
        default:
            positionLabel.text = "\(position)."
            positionLabel.isHidden = false
            medalImageView.isHidden = true
        }
    }

    fileprivate func drawShadow() {
        shadowPadView.backgroundColor = .clear

        let height = shadowPadView.frame.size.height
        let width = shadowPadView.frame.size.width
        let path = UIBezierPath()
        switch cellPosition {
        case .top:
            path.move(to: CGPoint.zero)
            path.addArc(withCenter: CGPoint(x: 10, y: 10), radius: 10, startAngle: -.pi, endAngle: -.pi / 2, clockwise: true)
            path.addLine(to: CGPoint(x: width - 10, y: 0))
            path.addArc(withCenter: CGPoint(x: width - 10, y: 10), radius: 10, startAngle: -.pi / 2, endAngle: 0, clockwise: true)
            path.addLine(to: CGPoint(x: width, y: height - 2.0))
            path.addLine(to: shadowPadView.center)
            path.addLine(to: CGPoint(x: 0, y: height - 2.0))
            path.close()
            shadowPadView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        case .middle:
            path.move(to: CGPoint.zero)
            path.addLine(to: shadowPadView.center)
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: shadowPadView.center)
            path.addLine(to: CGPoint(x: 0, y: height))
            path.close()
            shadowPadView.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        case .bottom:
            path.move(to: CGPoint.zero)
            path.addLine(to: shadowPadView.center)
            path.addLine(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: width, y: height))
            path.addArc(withCenter: CGPoint(x: width - 10, y: height - 10), radius: 10, startAngle: 0, endAngle: .pi / 2, clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addArc(withCenter: CGPoint(x: 10, y: height - 10), radius: 10, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
            path.close()
            shadowPadView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        }
        shadowPadView.layer.shadowPath = path.cgPath

        shadowPadView.layer.shadowOpacity = 0.2
        shadowPadView.layer.shadowRadius = 2.0
        shadowPadView.layer.shouldRasterize = true
        shadowPadView.layer.rasterizationScale = UIScreen.main.scale
    }

    fileprivate func drawRoundCorners() {
        let maskLayer = CAShapeLayer()
        if cellPosition == .top || cellPosition == .bottom {
            let path = UIBezierPath(roundedRect: cardPadView.bounds, byRoundingCorners: cellPosition == .top ? [.topRight, .topLeft] : [.bottomRight, .bottomLeft], cornerRadii: CGSize(width: 10, height: 10))
            maskLayer.path = path.cgPath
        } else {
            maskLayer.path = UIBezierPath(rect: cardPadView.bounds).cgPath
        }
        cardPadView.layer.mask = maskLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        drawRoundCorners()
        drawShadow()
    }
}
