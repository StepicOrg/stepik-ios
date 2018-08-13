//
//  StoriesViewController.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 04.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit
import Hero

class StoriesViewController: UIViewController {

    var presenter: StoriesPresenterProtocol?

    var stories: [Story] = []

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.skeleton.viewBuilder = { return UIView.fromNib(named: "StorySkeletonPlaceholderView") }

        collectionView.register(UINib(nibName: "StoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StoryCollectionViewCell")
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: 90, height: 90)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 16
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 16
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false

        refresh()
    }

    private func refresh() {
        collectionView.skeleton.show()
        presenter?.refresh()
    }

    private var willDisappear: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func showIfNotVisible(index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
    }

    func showStory(at index: Int) {

        let moduleToPresent = OpenedStoriesAssembly(stories: stories, startPosition: index).buildModule()
        moduleToPresent.view.hero.id = "story_\(stories[index].id)"
        present(moduleToPresent, animated: true, completion: nil)
    }
}

extension StoriesViewController: StoriesViewProtocol {
    func set(state: StoriesViewState) {
        switch state {
        case .empty:
            print("empty")
        case .normal:
            print("normal")
        case .loading:
            print("loading")
        }
    }

    func set(stories: [Story]) {
        collectionView.skeleton.hide()
        self.stories = stories
        collectionView.reloadData()
    }
}

extension StoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        cell.contentView.hero.id = "story_\(story.id)"
        cell.update(imagePath: story.coverPath, title: story.title)
        return cell
    }
}
