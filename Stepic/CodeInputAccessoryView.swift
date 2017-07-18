//
//  CodeInputAccessoryView.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CodeInputAccessoryView: UIView {
    
    @IBOutlet weak var hideKeyboardImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    var hideKeyboardAction: ((Void)->(Void))?
    
    var buttons : [CodeInputAccessoryButtonData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var size: CodeInputAccessorySize = .small
    
    fileprivate func initialize() {
        collectionView.register(UINib(nibName: "CodeInputAccessoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CodeInputAccessoryCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let tapG = UITapGestureRecognizer(target: self, action: #selector(CodeInputAccessoryView.didTapHideKeyboardImageView(recognizer:)))
        hideKeyboardImageView.addGestureRecognizer(tapG)
    }
    
    func didTapHideKeyboardImageView(recognizer: UIGestureRecognizer) {
        hideKeyboardAction?()
    }
    
    fileprivate var view: UIView!
    
    fileprivate func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        initialize()
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CodeInputAccessoryView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        setup()
    }
    
    convenience init(frame: CGRect, buttons: [CodeInputAccessoryButtonData], size: CodeInputAccessorySize, hideKeyboardAction: @escaping (Void)->(Void)) {
        self.init(frame: frame)
        self.buttons = buttons
        self.size = size
        self.hideKeyboardAction = hideKeyboardAction
    }
}

extension CodeInputAccessoryView : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CodeInputAccessoryCollectionViewCell.width(for: buttons[indexPath.item].title, size: size)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        buttons[indexPath.item].action()
    }
}

extension CodeInputAccessoryView : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CodeInputAccessoryCollectionViewCell", for: indexPath) as? CodeInputAccessoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.initialize(text: buttons[indexPath.item].title, size: size)
        
        return cell
    }
}

struct CodeInputAccessoryButtonData {
    var title: String
    var action: (Void) -> (Void)
    init(title: String, action: @escaping (Void) -> (Void)) {
        self.title = title
        self.action = action
    }
}
