//
//  StoriesViewController.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 04.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit

class StoriesViewController: UIViewController, ControllerWithStepikPlaceholder {
    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()

    var presenter: StoriesPresenterProtocol?

    var stories: [Story] = []
    var currentItemFrame: CGRect?

    @IBOutlet weak var collectionView: UICollectionView!

    private var willDisappear: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()

        registerPlaceholder(placeholder: StepikPlaceholder(.refreshStories, action: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.presenter?.refresh()
        }), for: .connectionError)

        transitioningDelegate = self
        modalPresentationStyle = .custom

        refresh()
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.skeleton.viewBuilder = { return UIView.fromNib(named: "StorySkeletonPlaceholderView") }

        collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryCollectionViewCell")
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: 98, height: 98)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 16
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 16
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func showStory(at index: Int) {
        let moduleToPresent = OpenedStoriesAssembly(stories: stories, startPosition: index).buildModule()
        moduleToPresent.modalPresentationStyle = .custom
        moduleToPresent.transitioningDelegate = self
        present(moduleToPresent, animated: true, completion: nil)
    }

    private func refresh() {
        presenter?.refresh()
    }

    private func getFrame(indexPath: IndexPath) -> CGRect? {
        if let frame = collectionView.cellForItem(at: indexPath)?.frame {
            return collectionView.convert(frame, to: UIApplication.shared.keyWindow)
        } else {
            return nil
        }
    }
}

extension StoriesViewController: StoriesViewProtocol {
    func set(state: StoriesViewState) {
        switch state {
        case .empty:
            collectionView.skeleton.hide()
            showPlaceholder(for: .connectionError)
        case .normal:
            collectionView.skeleton.hide()
            isPlaceholderShown = false
        case .loading:
            isPlaceholderShown = false
            collectionView.skeleton.show()
        }
    }

    func set(stories: [Story]) {
        self.stories = stories
        collectionView.reloadData()
    }

    func updateStory(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
        collectionView.reloadItems(at: [indexPath])
        DispatchQueue.main.async { [weak self] in
            self?.currentItemFrame = self?.getFrame(indexPath: indexPath)
        }
    }
}

extension StoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentItemFrame = getFrame(indexPath: indexPath)
        showStory(at: indexPath.item)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionViewCell", for: indexPath) as? StoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        let story = stories[indexPath.item]
        cell.update(imagePath: story.coverPath, title: story.title, isWatched: story.isViewed.value ?? true)
        return cell
    }
}

extension StoriesViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let currentItemFrame = currentItemFrame else {
            return nil
        }

        return GrowPresentAnimationController(originFrame: currentItemFrame)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
            let revealVC = dismissed as? OpenedStoriesPageViewController,
            let currentItemFrame = currentItemFrame
            else
        {
            return nil
        }

        return ShrinkDismissAnimationController(
            destinationFrame: currentItemFrame,
            interactionController: revealVC.swipeInteractionController
        )
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? ShrinkDismissAnimationController,
            let interactionController = animator.interactionController,
            interactionController.interactionInProgress
            else {
                return nil
        }
        return interactionController
    }
}
