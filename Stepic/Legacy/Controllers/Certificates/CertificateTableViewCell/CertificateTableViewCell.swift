import UIKit

final class CertificateTableViewCell: UITableViewCell {
    enum Appearance {
        static let editButtonTopOffset: CGFloat = 8

        static let actionButtonHeight: CGFloat = 31
    }

    @IBOutlet weak var courseTitle: StepikLabel!
    @IBOutlet weak var certificateDescription: StepikLabel!
    @IBOutlet weak var certificateResult: StepikLabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var courseImage: UIImageView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var editButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet var editButtonHeightConstraint: NSLayoutConstraint!

    private var viewData: CertificateViewData?

    var shareBlock: ((CertificateViewData, UIButton) -> Void)?
    var editBlock: ((CertificateViewData, UIButton) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.shareButton.setTitle(NSLocalizedString("Share", comment: ""), for: .normal)
        self.editButton.setTitle(NSLocalizedString("CertificateNameChangeAction", comment: ""), for: .normal)
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

        self.editButton.isHidden = !certificateViewData.isEditAvailable
        self.editButtonTopConstraint.constant = self.editButton.isHidden ? 0 : Appearance.editButtonTopOffset
        self.editButtonHeightConstraint.constant = self.editButton.isHidden
            ? 0
            : Appearance.actionButtonHeight
    }

    @IBAction
    func sharePressed(_ sender: UIButton) {
        if let viewData = self.viewData {
            self.shareBlock?(viewData, sender)
        }
    }

    @IBAction
    func editPressed(_ sender: UIButton) {
        guard let viewData = self.viewData,
              viewData.isEditAvailable else {
            return
        }

        self.editBlock?(viewData, sender)
    }
}
