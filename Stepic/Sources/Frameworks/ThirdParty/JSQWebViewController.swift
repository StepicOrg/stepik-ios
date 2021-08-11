// swiftlint:disable all
//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQWebViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQWebViewController
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
import WebKit

private let TitleKeyPath = "title"

private let EstimatedProgressKeyPath = "estimatedProgress"

/// An instance of `WebViewController` displays interactive web content.
class WebViewController: UIViewController {
    // MARK: Properties

    var allowsToOpenInSafari = true
    var backButtonStyle: BackButtonStyle = .done

    var onDismiss: (() -> Void)?

    /// Returns the web view for the controller.
    final var webView: WKWebView { _webView }

    /// Returns the progress view for the controller.
    final var progressBar: UIProgressView { _progressBar }

    /// The URL request for the web view. Upon setting this property, the web view immediately begins loading the request.
    final var urlRequest: URLRequest {
        didSet {
            webView.load(urlRequest)
        }
    }

    /**
     Specifies whether or not to display the web view title as the navigation bar title.
     The default is `false`, which sets the navigation bar title to the URL host name of the URL request.
     */
    final var displaysWebViewTitle = false

    // MARK: Private properties

    fileprivate lazy final var _webView: WKWebView = { [unowned self] in
        // FIXME: prevent Swift bug, lazy property initialized twice from `init(coder:)`
        // return existing webView if webView already added
        let views = self.view.subviews.filter { $0 is WKWebView } as! [WKWebView]
        if views.count != 0 {
            return views.first!
        }

        let webView = WKWebView(frame: CGRect.zero, configuration: self.configuration)
        self.view.addSubview(webView)
        webView.addObserver(self, forKeyPath: TitleKeyPath, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: EstimatedProgressKeyPath, options: .new, context: nil)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4"
        return webView
    }()

    fileprivate lazy final var _progressBar: UIProgressView = { [unowned self] in
        let progressBar = UIProgressView(progressViewStyle: .bar)
        progressBar.backgroundColor = UIColor.clear
        progressBar.trackTintColor = UIColor.clear
        self.view.addSubview(progressBar)
        return progressBar
    }()

    fileprivate final let configuration: WKWebViewConfiguration

    fileprivate final let activities: [UIActivity]?

    // MARK: Initialization

    /**
    Constructs a new `WebViewController`.

    - parameter urlRequest:    The URL request for the web view to load.
    - parameter configuration: The configuration for the web view.
    - parameter activities:    The custom activities to display in the `UIActivityViewController` that is presented when the action button is tapped.

    - returns: A new `WebViewController` instance.
    */
    init(
        urlRequest: URLRequest,
        configuration: WKWebViewConfiguration = WKWebViewConfiguration(),
        activities: [UIActivity]? = nil
    ) {
        self.configuration = configuration
        self.urlRequest = urlRequest
        self.activities = activities
        super.init(nibName: nil, bundle: nil)
    }

    /**
     Constructs a new `WebViewController`.
     
     - parameter url: The URL to display in the web view.
     
     - returns: A new `WebViewController` instance.
     */
    convenience init(url: URL) {
        self.init(urlRequest: URLRequest(url: url))
    }

    /// :nodoc:
    required init?(coder aDecoder: NSCoder) {
        self.configuration = WKWebViewConfiguration()
        self.urlRequest = URLRequest(url: NSURL(string: "")! as URL)
        self.activities = nil
        super.init(coder: aDecoder)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: TitleKeyPath, context: nil)
        webView.removeObserver(self, forKeyPath: EstimatedProgressKeyPath, context: nil)
    }

    // MARK: View lifecycle

    /// :nodoc:
    override func viewDidLoad() {
        super.viewDidLoad()
        title = urlRequest.url?.host

//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .Action,
//            target: self,
//            action: Selector("didTapActionButton:"))

        webView.load(urlRequest)
    }

    /// :nodoc:
    override func viewWillAppear(_ animated: Bool) {
        assert(navigationController != nil, "\(WebViewController.self) must be presented in a \(UINavigationController.self)")
        super.viewWillAppear(animated)

        if allowsToOpenInSafari {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: Images.safariBarButtonItemImage,
                style: UIBarButtonItem.Style.plain,
                target: self,
                action: #selector(WebViewController.didTapSafariButton(_:)))
            navigationItem.rightBarButtonItem?.tintColor = UIColor.stepikAccent
        }

        if presentingViewController?.presentedViewController != nil {
            let doneItem = backButtonStyle.barButtonItem
            doneItem.target = self
            doneItem.action = #selector(WebViewController.didTapDoneButton(_:))
            navigationItem.leftBarButtonItem = doneItem
            //            navigationItem.leftBarButtonItem = UIBarButtonItem(
            //                barButtonSystemItem: .Done,
            //                target: self,
            //                action: Selector("didTapDoneButton:"))
        }
    }

    /// :nodoc:
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.stopLoading()
    }

    /// :nodoc:
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds

        let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
        webView.scrollView.contentInset = insets
        webView.scrollView.scrollIndicatorInsets = insets

        view.bringSubviewToFront(progressBar)
        progressBar.frame = CGRect(
            x: view.frame.minX,
            y: topLayoutGuide.length,
            width: view.frame.size.width,
            height: 2)
    }

    // MARK: Actions

    @objc final func didTapDoneButton(_ sender: UIBarButtonItem) {
        onDismiss?()
    }

    @objc final func didTapSafariButton(_ sender: UIBarButtonItem) {
        if let url = webView.url {
            UIApplication.shared.openURL(url)
        }
    }

    final func didTapActionButton(_ sender: UIBarButtonItem) {
        if let url = urlRequest.url {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: activities)
            activityVC.popoverPresentationController?.barButtonItem = sender
            present(activityVC, animated: true, completion: nil)
        }
    }

    // MARK: KVO

    /// :nodoc:
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let theKeyPath = keyPath, object as? WKWebView == webView else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if displaysWebViewTitle && theKeyPath == TitleKeyPath {
            title = webView.title
        }

        if theKeyPath == EstimatedProgressKeyPath {
            updateProgress()
        }
    }

    // MARK: Private

    fileprivate final func updateProgress() {
        let completed = webView.estimatedProgress == 1.0
        progressBar.setProgress(completed ? 0.0 : Float(webView.estimatedProgress), animated: !completed)
        UIApplication.shared.isNetworkActivityIndicatorVisible = !completed
    }
}
