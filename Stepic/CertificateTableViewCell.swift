//
//  CertificateTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class CertificateTableViewCell: UITableViewCell {
    @IBOutlet weak var courseTitle: StepikLabel!
    @IBOutlet weak var certificateDescription: StepikLabel!
    @IBOutlet weak var certificateResult: StepikLabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var courseImage: UIImageView!

    private var viewData: CertificateViewData?

    var shareBlock: ((CertificateViewData, UIButton) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.shareButton.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
    }

    func initWith(certificateViewData: CertificateViewData) {
        self.viewData = certificateViewData
        self.courseTitle.text = certificateViewData.courseName
        self.certificateDescription.text = certificateViewData.certificateDescription
        self.certificateResult.text = "\(NSLocalizedString("Result", comment: "")): \(certificateViewData.grade)%"
        self.courseImage.setImageWithURL(
            url: certificateViewData.courseImageURL,
            placeholder: Images.lessonPlaceholderImage.size50x50
        )
    }

    @IBAction func sharePressed(_ sender: UIButton) {
        if let viewData = self.viewData {
            self.shareBlock?(viewData, sender)
        }
    }
}
