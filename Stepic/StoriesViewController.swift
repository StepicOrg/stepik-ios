//
//  StoriesViewController.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 04.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Presentr
import UIKit

final class StoriesViewController: UIViewController, ControllerWithStepikPlaceholder {
    var placeholderContainer = StepikPlaceholderControllerContainer()

    var presenter: StoriesPresenterProtocol?

    private var stories: [Story] = []
    private var currentItemFrame: CGRect?

    @IBOutlet weak var collectionView: UICollectionView!

    private var willDisappear = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCollectionView()

        self.registerPlaceholder(placeholder: StepikPlaceholder(.refreshStories, action: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.presenter?.refresh()
        }), for: .connectionError)

        self.transitioningDelegate = self
        self.modalPresentationStyle = .custom

        self.refresh()
    }

    private func setupCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.skeleton.viewBuilder = { UIView.fromNib(named: "StorySkeletonPlaceholderView") }

        self.collectionView.register(
            UINib(nibName: "StoryCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "StoryCollectionViewCell"
        )

        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 98, height: 98)
            layout.minimumInteritemSpacing = 16
            layout.minimumLineSpacing = 16
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            layout.scrollDirection = .horizontal
        }

        self.collectionView.showsHorizontalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    let storyPresentr: Presentr = {
        let sourcePortraitHeight = Float(max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.8)
        let sourcePortraitWidth: Float = sourcePortraitHeight * 9 / 16
        let sourceLandscapeHeight = Float(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.8)
        let sourceLandscapeWidth: Float = sourceLandscapeHeight * 9 / 16

        let height = ModalSize.customOrientation(sizePortrait: sourcePortraitHeight, sizeLandscape: sourceLandscapeHeight)
        let width = ModalSize.customOrientation(sizePortrait: sourcePortraitWidth, sizeLandscape: sourceLandscapeWidth)

        let presentr = Presentr(presentationType: .custom(width: width, height: height, center: .center))
        presentr.backgroundOpacity = 0.5
        presentr.backgroundTap = .noAction
        presentr.dismissAnimated = true
        presentr.dismissTransitionType = TransitionType.coverVertical
        presentr.roundCorners = true
        presentr.cornerRadius = 8
        presentr.dropShadow = PresentrShadow(
            shadowColor: .black,
            shadowOpacity: 0.3,
            shadowOffset: CGSize(width: 0.0, height: 0.0),
            shadowRadius: 1.2
        )

        return presentr
    }()

    func showStory(at index: Int) {
        let moduleToPresent = OpenedStoriesAssembly(
            stories: self.stories,
            startPosition: index,
            moduleOutput: self.presenter as? OpenedStoriesOutputProtocol
        ).makeModule()
        if DeviceInfo.current.isPad {
            self.customPresentViewController(
                self.storyPresentr,
                viewController: moduleToPresent,
                animated: true,
                completion: nil
            )
        } else {
            moduleToPresent.modalPresentationStyle = .custom
            moduleToPresent.transitioningDelegate = self
            self.present(moduleToPresent, animated: true, completion: nil)
        }
    }

    private func refresh() {
        self.presenter?.refresh()
    }

    private func getFrame(indexPath: IndexPath) -> CGRect? {
        if let frame = self.collectionView.cellForItem(at: indexPath)?.frame {
            return self.collectionView.convert(frame, to: UIApplication.shared.keyWindow)
        } else {
            return nil
        }
    }
}

extension StoriesViewController: StoriesViewProtocol {
    func set(state: StoriesViewState) {
        switch state {
        case .empty:
            self.collectionView.skeleton.hide()
            self.showPlaceholder(for: .connectionError)
        case .normal:
            self.collectionView.skeleton.hide()
            self.isPlaceholderShown = false
        case .loading:
            self.isPlaceholderShown = false
            self.collectionView.skeleton.show()
        }
    }

    func set(stories: [Story]) {
        self.stories = stories
        self.collectionView.reloadData()
    }

    func updateStory(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        if !self.collectionView.indexPathsForVisibleItems.contains(indexPath) {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }

        self.collectionView.reloadItems(at: [indexPath])

        DispatchQueue.main.async { [weak self] in
            self?.currentItemFrame = self?.getFrame(indexPath: indexPath)
        }
    }
}

extension StoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentItemFrame = self.getFrame(indexPath: indexPath)
        self.showStory(at: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.stories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "StoryCollectionViewCell",
            for: indexPath
        ) as? StoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        let story = self.stories[indexPath.item]
        cell.update(imagePath: story.coverPath, title: story.title, isWatched: story.isViewed.value)

        return cell
    }
}

extension StoriesViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let currentItemFrame = self.currentItemFrame else {
            return nil
        }

        return GrowPresentAnimationController(originFrame: currentItemFrame)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let revealVC = dismissed as? OpenedStoriesPageViewController,
              let currentItemFrame = self.currentItemFrame else {
            return nil
        }

        return ShrinkDismissAnimationController(
            destinationFrame: currentItemFrame,
            interactionController: revealVC.swipeInteractionController
        )
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? ShrinkDismissAnimationController,
              let interactionController = animator.interactionController,
              interactionController.interactionInProgress else {
            return nil
        }

        return interactionController
    }
}
