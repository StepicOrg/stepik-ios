//
//  SocialAuthViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SocialAuthViewController: UIViewController {
    fileprivate let numberOfColumns = 3
    fileprivate let numberOfRows = 2
    fileprivate let headerHeight: CGFloat = 47.0

    var isExpanded = false

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBAction func onCloseClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .social, to: nil)
        }
    }

    @IBAction func onSignInWithEmailClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .social, to: .email)
        }
    }

    @IBAction func onSignUpClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .social, to: .registration)
        }
    }

    @IBAction func moreButtonClick(_ sender: Any) {
        isExpanded = !isExpanded

        moreButton.setTitle(isExpanded ? "Less" : "More", for: .normal)

        collectionView.collectionViewLayout.invalidateLayout()
        self.updateCollectionViewHeight()
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "SocialAuthCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: SocialAuthCollectionViewCell.reuseId)

        let collectionViewLayout = SocialCollectionViewFlowLayout()
        collectionViewLayout.numberOfColumns = numberOfColumns
        collectionView.collectionViewLayout = collectionViewLayout
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func updateCollectionViewHeight() {
        guard let layout = self.collectionView.collectionViewLayout as? SocialCollectionViewFlowLayout else {
            return
        }

        // Add additional offset for shadows
        collectionViewHeight.constant = isExpanded ? (2 * layout.itemSize.height + layout.minimumInteritemSpacing + headerHeight) + 10 : (layout.itemSize.height + headerHeight) + 5
    }
}

extension SocialAuthViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfColumns
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfRows
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SocialAuthCollectionViewCell.reuseId, for: indexPath) as! SocialAuthCollectionViewCell

        // Just for test
        if indexPath.section == 0 {
            switch indexPath.item {
            case 0:
                cell.socialButton.setImage(#imageLiteral(resourceName: "vk"), for: .normal)
            case 1:
                cell.socialButton.setImage(#imageLiteral(resourceName: "fb"), for: .normal)
            case 2:
                cell.socialButton.setImage(#imageLiteral(resourceName: "google"), for: .normal)
            default:
                cell.socialButton.setImage(nil, for: .normal)
            }
        }
        if indexPath.section == 1 {
            switch indexPath.item {
            case 0:
                cell.socialButton.setImage(#imageLiteral(resourceName: "twitter"), for: .normal)
            case 1:
                cell.socialButton.setImage(#imageLiteral(resourceName: "github"), for: .normal)
            case 2:
                cell.socialButton.setImage(#imageLiteral(resourceName: "mail"), for: .normal)
            default:
                cell.socialButton.setImage(nil, for: .normal)
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let layout = collectionViewLayout as? SocialCollectionViewFlowLayout else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        // Center grid
        let width = collectionView.bounds.width
        let contentWidth = CGFloat(CGFloat(layout.numberOfColumns - 1) * layout.minimumInteritemSpacing + CGFloat(layout.numberOfColumns) * layout.itemSize.width)
        let leftOffset = (width - contentWidth) / 2

        // Add bottom offset for first section
        if section == 0 {
            return UIEdgeInsets(top: 0, left: leftOffset, bottom: layout.minimumLineSpacing, right: leftOffset)
        }
        return UIEdgeInsets(top: 0, left: leftOffset, bottom: 0, right: leftOffset)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SocialAuthHeaderView.reuseId, for: indexPath)
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        // Add caption only for first section
        return section == 0 ? CGSize(width: collectionView.bounds.size.width, height: headerHeight) : CGSize.zero
    }
}

class SocialCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var numberOfColumns: Int = 3
    var itemSizeHeight: CGFloat = 51.0

    private func setup() {
        minimumLineSpacing = 27.0
        minimumInteritemSpacing = 23.0
        scrollDirection = .vertical
    }

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override var itemSize: CGSize {
        set { }
        get {
            return CGSize(width: itemSizeHeight, height: itemSizeHeight)
        }
    }
}
