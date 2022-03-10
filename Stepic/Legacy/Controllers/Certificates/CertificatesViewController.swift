import SVProgressHUD
import UIKit

@available(*, deprecated, message: "Class to initialize certificates w/o storyboards logic")
final class CertificatesLegacyAssembly: Assembly {
    private let userID: User.IdType

    init(userID: User.IdType) {
        self.userID = userID
    }

    func makeModule() -> UIViewController {
        guard let certificatesVC = ControllerHelper.instantiateViewController(
            identifier: "CertificatesViewController",
            storyboardName: "CertificatesStoryboard"
        ) as? CertificatesViewController else {
            fatalError("Unable to initialize CertificatesViewController via storyboard")
        }

        certificatesVC.userID = self.userID
        certificatesVC.presenter = CertificatesPresenter(
            userID: self.userID,
            certificatesRepository: CertificatesRepository.default,
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            userAccountService: UserAccountService(),
            view: certificatesVC
        )
        certificatesVC.analytics = StepikAnalytics.shared

        return certificatesVC
    }
}

// MARK: - CertificatesViewController -

final class CertificatesViewController: UIViewController, ControllerWithStepikPlaceholder {
    var placeholderContainer = StepikPlaceholderControllerContainer()

    @IBOutlet weak var tableView: StepikTableView!

    private lazy var refreshControl = UIRefreshControl()
    private lazy var paginationView: LoadingPaginationView = {
        let paginationView = LoadingPaginationView()
        paginationView.refreshAction = { [weak self] in
            guard let presenter = self?.presenter else {
                return
            }

            if presenter.getNextPage() {
                self?.paginationView.setLoading()
            }
        }
        paginationView.setLoading()
        return paginationView
    }()

    private weak var changeCertificateNameTextField: UITextField?
    private weak var changeCertificateNameOKAction: UIAlertAction?

    var presenter: CertificatesPresenter?
    var userID: User.IdType?

    var analytics: Analytics?

    private var certificates: [CertificateViewData] = []
    private var showNextPageFooter = false

    private var hasLoadedData = false {
        didSet {
            self.updateEmptySetPlaceholder()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        self.tableView.loadingPlaceholder = StepikPlaceholder(.emptyCertificatesLoading)

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnection, action: { [weak self] in
            self?.presenter?.refreshCertificates()
        }), for: .connectionError)

        title = NSLocalizedString("Certificates", comment: "")

        tableView.register(
            UINib(nibName: "CertificateTableViewCell", bundle: nil),
            forCellReuseIdentifier: "CertificateTableViewCell"
        )

        self.tableView.estimatedRowHeight = 161
        self.tableView.rowHeight = UITableView.automaticDimension

        refreshControl.addTarget(
            self,
            action: #selector(CertificatesViewController.refreshCertificates),
            for: .valueChanged
        )
        tableView.refreshControl = refreshControl
        refreshControl.layoutIfNeeded()
        refreshControl.beginRefreshing()

        presenter?.getCachedCertificates()
        presenter?.refreshCertificates()

        self.view.backgroundColor = .stepikGroupedBackground
        self.tableView.backgroundColor = .stepikGroupedBackground
        self.tableView.contentInsetAdjustmentBehavior = .never

        DispatchQueue.main.async {
            self.displayRefreshing()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.analytics?.send(.certificatesScreenOpened)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showProfile" {
            let dvc = segue.destination
            dvc.hidesBottomBarWhenPushed = true
        }
    }

    private func updateEmptySetPlaceholder() {
        if self.hasLoadedData {
            let isMe = AuthInfo.shared.userId != nil && self.userID == AuthInfo.shared.userId
            if isMe {
                self.tableView.emptySetPlaceholder = StepikPlaceholder(.emptyCertificatesMe) {
                    TabBarRouter(tab: .catalog()).route()
                }
            } else {
                self.tableView.emptySetPlaceholder = StepikPlaceholder(.emptyCertificatesOther)
            }
        } else {
            self.tableView.emptySetPlaceholder = nil
        }
    }

    private func shareCertificate(certificate: CertificateViewData, button: UIButton) {
        guard let url = certificate.certificateURL else {
            return
        }

        self.analytics?.send(
            .shareCertificateTapped(grade: certificate.grade, courseName: certificate.courseName ?? "")
        )

        DispatchQueue.global(qos: .background).async {
            let sharingViewController = SharingHelper.getSharingController(url.absoluteString)
            DispatchQueue.main.async {
                sharingViewController.popoverPresentationController?.sourceView = button
                self.present(sharingViewController, animated: true, completion: nil)
            }
        }
    }

    @objc
    private func refreshCertificates() {
        presenter?.refreshCertificates()
    }

    private func loadNextPage() {
        guard let presenter = presenter else {
            return
        }

        if presenter.getNextPage() {
            self.paginationView.setLoading()
        }
    }
}

// MARK: - CertificatesViewController: CertificatesView -

extension CertificatesViewController: CertificatesView {
    func setCertificates(certificates: [CertificateViewData], hasNextPage: Bool) {
        self.hasLoadedData = true

        self.certificates = certificates
        self.showNextPageFooter = hasNextPage

        CATransaction.begin()
        CATransaction.setCompletionBlock({
            [weak self] in
            self?.tableView.reloadData()
        })
        refreshControl.endRefreshing()
        CATransaction.commit()
    }

    func displayError() {
        refreshControl.endRefreshing()
        showPlaceholder(for: .connectionError)
    }

    func displayEmpty() {
        refreshControl.endRefreshing()
        tableView.reloadData()
        self.isPlaceholderShown = false
    }

    func displayRefreshing() {
        tableView.showLoadingPlaceholder()
        self.isPlaceholderShown = false
    }

    func displayLoadNextPageError() {
        self.paginationView.setError()
    }
}

// MARK: - CertificatesViewController: UITableViewDelegate -

extension CertificatesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard showNextPageFooter else {
            return UIView()
        }

        return paginationView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 0.1 }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        self.showNextPageFooter ? 60.0 : 0.1
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard certificates.count > indexPath.row else {
            return
        }

        guard let url = certificates[indexPath.row].certificateURL else {
            return
        }

        self.analytics?.send(
            .certificateOpened(
                grade: certificates[indexPath.row].grade,
                courseName: certificates[indexPath.row].courseName ?? ""
            )
        )

        WebControllerManager.shared.presentWebControllerWithURL(
            url,
            inController: self,
            withKey: .certificate,
            allowsSafari: true,
            backButtonStyle: .close
        )
    }
}

// MARK: - CertificatesViewController: UITableViewDataSource -

extension CertificatesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.certificates.isEmpty ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { certificates.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard certificates.count > indexPath.row else {
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "CertificateTableViewCell",
            for: indexPath
        ) as? CertificateTableViewCell else {
            return UITableViewCell()
        }

        cell.initWith(certificateViewData: certificates[indexPath.row])

        cell.shareBlock = { [weak self] viewData, button in
            self?.shareCertificate(certificate: viewData, button: button)
        }
        cell.editBlock = { [weak self] viewData, _ in
            self?.promptForChangeCertificateNameInput(certificate: viewData)
        }

        if certificates.count == indexPath.row + 1 && showNextPageFooter {
            loadNextPage()
        }

        return cell
    }
}

// MARK: - CertificatesViewController (Certificate Change Name) -

extension CertificatesViewController {
    private func promptForChangeCertificateNameInput(
        certificate: CertificateViewData,
        predefinedNewFullName: String? = nil
    ) {
        let message = String(
            format: NSLocalizedString("CertificateNameChangeAlertMessageWarning", comment: ""),
            arguments: [FormatterHelper.timesCount(certificate.allowedEditsCount)]
        )

        let alert = UIAlertController(
            title: NSLocalizedString("CertificateNameChangeAlertTitle", comment: ""),
            message: message,
            preferredStyle: .alert
        )

        alert.addTextField()
        self.changeCertificateNameTextField = alert.textFields?.first
        self.changeCertificateNameTextField?.placeholder = NSLocalizedString(
            "CertificateNameChangeAlertTextFieldPlaceholder",
            comment: ""
        )
        self.changeCertificateNameTextField?.delegate = self
        if let predefinedNewFullName = predefinedNewFullName {
            self.changeCertificateNameTextField?.text = predefinedNewFullName
        }

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        let okAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default,
            handler: { [weak self, weak alert] _ in
                guard let strongSelf = self,
                      let strongAlert = alert else {
                    return
                }

                guard let text = strongAlert.textFields?.first?.text?.trimmed(),
                      !text.isEmpty else {
                    return SVProgressHUD.showError(
                        withStatus: NSLocalizedString("CertificateNameChangeEmptyTextFieldErrorMessage", comment: "")
                    )
                }

                strongSelf.promptForChangeCertificateName(certificate: certificate, newFullName: text)
            }
        )
        okAction.isEnabled = !(predefinedNewFullName ?? "").trimmed().isEmpty
        alert.addAction(okAction)
        self.changeCertificateNameOKAction = okAction

        self.present(alert, animated: true)
    }

    private func promptForChangeCertificateName(certificate: CertificateViewData, newFullName: String) {
        var message = String(
            format: NSLocalizedString("CertificateNameChangeAlertMessageConfirmation", comment: ""),
            arguments: [certificate.savedFullName, newFullName]
        )

        let isLastEdit = (certificate.editsCount + 1) == certificate.allowedEditsCount
        if isLastEdit {
            message += "\n\(NSLocalizedString("CertificateNameChangeAlertMessageLastEditWarning", comment: ""))"
        }

        let alert = UIAlertController(
            title: NSLocalizedString("CertificateNameChangeAlertTitle", comment: ""),
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    SVProgressHUD.show()

                    strongSelf.presenter?.updateCertificateName(
                        viewDataUniqueIdentifier: certificate.uniqueIdentifier,
                        newFullName: newFullName
                    ).done { updatedCertificate in
                        SVProgressHUD.showSuccess(
                            withStatus: NSLocalizedString("CertificateNameChangeSuccessStatusMessage", comment: "")
                        )

                        let certificateIndexOrNil = strongSelf.certificates.firstIndex(
                            where: { $0.uniqueIdentifier == updatedCertificate.uniqueIdentifier }
                        )

                        if let certificateIndex = certificateIndexOrNil {
                            strongSelf.certificates[certificateIndex] = updatedCertificate
                            strongSelf.tableView.reloadData()
                        }
                    }.catch { _ in
                        SVProgressHUD.showError(
                            withStatus: NSLocalizedString("CertificateNameChangeErrorStatusMessage", comment: "")
                        )
                        strongSelf.promptForChangeCertificateNameInput(
                            certificate: certificate,
                            predefinedNewFullName: newFullName
                        )
                    }
                }
            )
        )

        self.present(alert, animated: true)
    }
}

// MARK: - CertificatesViewController: UITextFieldDelegate -

extension CertificatesViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard self.changeCertificateNameTextField === textField else {
            return true
        }

        let stringFromTextField = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""

        self.changeCertificateNameOKAction?.isEnabled = !stringFromTextField.trimmed().isEmpty

        return true
    }
}
