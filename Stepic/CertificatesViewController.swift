//
//  CertificatesViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CertificatesViewController: UIViewController, CertificatesView, ControllerWithStepikPlaceholder {

    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()

    @IBOutlet weak var tableView: StepikTableView!

    var presenter: CertificatesPresenter?

    var certificates: [CertificateViewData] = []
    var showNextPageFooter: Bool = false

    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.emptySetPlaceholder = StepikPlaceholder(.emptyCertificates) { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
        tableView.loadingPlaceholder = StepikPlaceholder(.emptyCertificatesLoading)

        registerPlaceholder(placeholder: StepikPlaceholder(.login, action: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            RoutingManager.auth.routeFrom(controller: strongSelf, success: nil, cancel: nil)
        }), for: .anonymous)
        registerPlaceholder(placeholder: StepikPlaceholder(.noConnection, action: { [weak self] in
            self?.presenter?.checkStatus()
        }), for: .connectionError)

        title = NSLocalizedString("Certificates", comment: "")

        presenter = CertificatesPresenter(certificatesAPI: ApiDataDownloader.certificates, coursesAPI: ApiDataDownloader.courses, presentationContainer: PresentationContainer.certificates, view: self)
        presenter?.view = self

        tableView.register(UINib(nibName: "CertificateTableViewCell", bundle: nil), forCellReuseIdentifier: "CertificateTableViewCell")

        self.tableView.estimatedRowHeight = 161
        self.tableView.rowHeight = UITableViewAutomaticDimension

        refreshControl.addTarget(self, action: #selector(CertificatesViewController.refreshCertificates), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.layoutIfNeeded()
        refreshControl.beginRefreshing()

        presenter?.refreshCertificates()

        tableView.backgroundColor = UIColor.groupTableViewBackground
        initPaginationView()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Certificates.opened.send()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.checkStatus()
    }

    fileprivate func initPaginationView() {
        paginationView = LoadingPaginationView()
        paginationView?.refreshAction = {
            [weak self] in

            guard let presenter = self?.presenter else {
                return
            }

            if presenter.getNextPage() {
                self?.paginationView?.setLoading()
            }
        }

        paginationView?.setLoading()
    }

    func shareCertificate(certificate: CertificateViewData, button: UIButton) {
        guard let url = certificate.certificateURL else {
            return
        }

        AnalyticsReporter.reportEvent(AnalyticsEvents.Certificates.shared, parameters: [
            "grade": certificate.grade,
            "course": certificate.courseName ?? ""
            ])

        DispatchQueue.global(qos: .background).async {
            let shareVC = SharingHelper.getSharingController(url.absoluteString)
            shareVC.popoverPresentationController?.sourceView = button
            DispatchQueue.main.async {
                self.present(shareVC, animated: true, completion: nil)
            }
        }
    }

    @objc func refreshCertificates() {
        presenter?.refreshCertificates()
    }

    func setCertificates(certificates: [CertificateViewData], hasNextPage: Bool) {
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

    func displayAnonymous() {
        refreshControl.endRefreshing()
        showPlaceholder(for: .anonymous)
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
        paginationView?.setError()
    }

    func updateData() {
        tableView.reloadData()
    }

    var paginationView: LoadingPaginationView?

    func loadNextPage() {
        guard let presenter = presenter else {
            return
        }

        if presenter.getNextPage() {
            paginationView?.setLoading()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showProfile" {
            let dvc = segue.destination
            dvc.hidesBottomBarWhenPushed = true
        }
    }
}

extension CertificatesViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard showNextPageFooter else {
            return UIView()
        }

        return paginationView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return showNextPageFooter ? 60.0 : 0.1
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        guard certificates.count > indexPath.row else {
            return
        }

        guard let url = certificates[indexPath.row].certificateURL else {
            return
        }

        AnalyticsReporter.reportEvent(AnalyticsEvents.Certificates.opened, parameters: [
            "grade": certificates[indexPath.row].grade,
            "course": certificates[indexPath.row].courseName ?? ""
            ])

        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "certificate", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
    }
}

extension CertificatesViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return certificates.count == 0 ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return certificates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard certificates.count > indexPath.row else {
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CertificateTableViewCell", for: indexPath) as? CertificateTableViewCell else {
            return UITableViewCell()
        }

        cell.initWith(certificateViewData: certificates[indexPath.row])

        cell.shareBlock = {
            [weak self]
            viewData, button in
            self?.shareCertificate(certificate: viewData, button: button)
        }

        if certificates.count == indexPath.row + 1 && showNextPageFooter {
            loadNextPage()
        }

        return cell
    }
}
