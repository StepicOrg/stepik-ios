//
//  CertificatesViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import DZNEmptyDataSet

enum CertificatesEmptyDatasetState {
    case anonymous, error, empty, refreshing
}

class CertificatesViewController : UIViewController, CertificatesView {
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: CertificatesPresenter?
    
    var certificates : [CertificateViewData] = []
    var showNextPageFooter: Bool = false
    var emptyState : CertificatesEmptyDatasetState = .empty {
        didSet {
            tableView.reloadEmptyDataSet()
        }
    }
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    
        presenter = CertificatesPresenter(certificatesAPI: ApiDataDownloader.certificates, coursesAPI: ApiDataDownloader.courses)
        presenter?.view = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
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
        
        tableView.backgroundColor = UIColor.white
        
        initPaginationView()
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
    
    func refreshCertificates() {
        presenter?.refreshCertificates()
    }
    
    func setCertificates(certificates: [CertificateViewData], hasNextPage: Bool) {
        self.certificates = certificates
        self.showNextPageFooter = hasNextPage
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func displayAnonymous() {
        refreshControl.endRefreshing()
        emptyState = .anonymous
    }
    
    func displayError() {
        refreshControl.endRefreshing()
        emptyState = .error
    }
    
    func displayEmpty() {
        refreshControl.endRefreshing()
        emptyState = .empty
    }
    
    func displayRefreshing() {
        emptyState = .refreshing
    }
    
    func displayLoadNextPageError() {
        tableView.beginUpdates()
        tableView.endUpdates()
        paginationView?.setError()
    }
    
    func updateData() {
        tableView.reloadData()
    }
    
    var paginationView : LoadingPaginationView? = nil
    
    func loadNextPage() {
        guard let presenter = presenter else {
            return
        }
        
        if presenter.getNextPage() {
            paginationView?.setLoading()
        }
    }
}

extension CertificatesViewController : DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        switch emptyState {
        case .anonymous:
            let vc = ControllerHelper.getAuthController()
            self.present(vc, animated: true, completion: nil)
            break
            
        case .empty:
            self.tabBarController?.selectedIndex = 1
            break
            
        case .error:
            break
            
        case .refreshing:
            break
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
        return showNextPageFooter ? 0.1 : 40.0
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
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
        
        if certificates.count == indexPath.row + 1 {
            loadNextPage()
        }
        
        return cell
    }
}

extension CertificatesViewController : DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        //Add correct placeholders here
        switch emptyState {
        case .anonymous:
            return Images.emptyCoursesPlaceholder
        case .empty:
            return Images.emptyCoursesPlaceholder
        case .error:
            return Images.noWifiImage.size250x250
        case .refreshing:
            return Images.emptyCoursesPlaceholder
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        
        switch emptyState {
        case .anonymous:
            text = "Anonymous users can't have certificates"
        case .empty:
            text = NSLocalizedString("EmptyMyCoursesTitle", comment: "")
            break
        case .error:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
            break
        case .refreshing:
            text = NSLocalizedString("Refreshing", comment: "")
            break
        }
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0),
                          NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        
        switch emptyState {
        case .anonymous:
            text = NSLocalizedString("SignInToJoin", comment: "")
            break
        case .empty:
            text = NSLocalizedString("EmptyMyCoursesDescription", comment: "")
            break
        case .error:
            text = NSLocalizedString("ConnectionErrorPullToRefresh", comment: "")
            break
        case .refreshing:
            text = NSLocalizedString("RefreshingDescription", comment: "")
            break
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0),
                          NSForegroundColorAttributeName: UIColor.lightGray,
                          NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        var text : String = ""
        switch emptyState {
        case .anonymous:
            text = NSLocalizedString("SignIn", comment: "")
        case .empty:
            text = NSLocalizedString("AllCourses", comment: "")
        case .error:
            text = ""
            break
        case .refreshing:
            text = ""
            break
        }
        
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0),
                          NSForegroundColorAttributeName: UIColor.stepicGreenColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
}
