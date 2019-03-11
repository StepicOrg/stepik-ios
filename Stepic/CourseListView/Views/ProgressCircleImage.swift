//
//  ProgressCircleImage.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ProgressCircleImage {
    private var size: CGSize
    private var progress: Float
    private var backgroundColor: UIColor
    private var progressColor: UIColor
    private var lineWidth: CGFloat

    lazy var uiImage: UIImage? = self.makeProgressImage()

    init(
        progress: Float,
        size: CGSize,
        lineWidth: CGFloat,
        backgroundColor: UIColor,
        progressColor: UIColor
    ) {
        self.size = size
        self.progress = progress
        self.backgroundColor = backgroundColor
        self.progressColor = progressColor
        self.lineWidth = lineWidth
    }

    private func makeRingShapeLayer(
        color: UIColor,
        sectorPart: Float,
        width: CGFloat,
        lineWidth: CGFloat
    ) -> CAShapeLayer {
        let circle = CAShapeLayer()

        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = color.cgColor
        circle.lineWidth = lineWidth
        circle.strokeEnd = CGFloat(sectorPart)
        circle.lineJoin = kCALineJoinRound

        circle.path = UIBezierPath(
            arcCenter: CGPoint(
                x: width / 2.0,
                y: width / 2.0
            ),
            radius: width / 2.0 - lineWidth,
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        ).cgPath
        return circle
    }

    private func makeProgressImage() -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)

        let progressView = UIView(frame: rect)
        progressView.backgroundColor = UIColor.clear

        let backgroundCircle = self.makeRingShapeLayer(
            color: self.backgroundColor,
            sectorPart: 1.0,
            width: self.size.width,
            lineWidth: self.lineWidth
        )

        let progressCircle = self.makeRingShapeLayer(
            color: self.progressColor,
            sectorPart: self.progress,
            width: self.size.width,
            lineWidth: self.lineWidth
        )

        progressView.layer.insertSublayer(backgroundCircle, at: 1)
        progressView.layer.insertSublayer(progressCircle, at: 2)

        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }

        guard let currentContext = UIGraphicsGetCurrentContext() else {
            return nil
        }

        progressView.layer.render(in: currentContext)

        guard let renderedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        return renderedImage
    }

}
