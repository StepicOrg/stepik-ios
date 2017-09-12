//
//  CertificateTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CertificateTableViewCell: UITableViewCell {

    @IBOutlet weak var courseTitle: StepikLabel!
    @IBOutlet weak var certificateDescription: StepikLabel!
    @IBOutlet weak var certificateResult: StepikLabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var courseImage: UIImageView!

    var viewData: CertificateViewData?

    var shareBlock: ((CertificateViewData, UIButton) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        certificateDescription.isGray = true
        shareButton.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWith(certificateViewData: CertificateViewData) {
        self.viewData = certificateViewData
        courseTitle.text = certificateViewData.courseName
        certificateDescription.text = certificateViewData.certificateDescription
        certificateResult.text = "\(NSLocalizedString("Result", comment: "")): \(certificateViewData.grade)%"
        courseImage.setImageWithURL(url: certificateViewData.courseImageURL, placeholder: Images.lessonPlaceholderImage.size50x50)
    }

    @IBAction func sharePressed(_ sender: UIButton) {
        guard let viewData = viewData else {
            return
        }
        shareBlock?(viewData, sender)
    }

}
