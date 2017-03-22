//
//  StreaksView.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class StreaksView: UIView {
    
    
    @IBOutlet weak var currentStreakLabel: UILabel!
    
    @IBOutlet weak var currentStreakCountLabel: UILabel!
    
    @IBOutlet weak var currentStreakDaysInARowLabel: UILabel!
    
    @IBOutlet weak var bestStreakLabel: UILabel!
     
    @IBOutlet weak var bestStreakCountLabel: UILabel!
    
    @IBOutlet weak var bestStreakDaysInARowLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    fileprivate var currentStreak : Int = 0 {
        didSet {
            currentStreakCountLabel.text = "\(currentStreak)"
            currentStreakDaysInARowLabel.text = "\(dayLocalizableFor(daysCnt: currentStreak)) \(NSLocalizedString("InARow", comment: ""))"
            if bestStreak != 0 {
                currentStreakCountLabel.textColor = color(index: min((currentStreak * 10) / bestStreak, colorsInt.count - 1))
            } else {
                bestStreakCountLabel.textColor = color(index: colorsInt.count - 1)
            }
        }
    }
    
    fileprivate var bestStreak : Int = 0 {
        didSet {
            bestStreakCountLabel.text = "\(bestStreak)"
            bestStreakDaysInARowLabel.text = dayLocalizableFor(daysCnt: bestStreak)
            bestStreakCountLabel.textColor = color(index: colorsInt.count - 1)
        }
    }
    
    var loading : Bool = false {
        didSet {
            if loading {
                loadingView.isHidden = false
                loadingActivityIndicator.startAnimating()
            } else {
                loadingActivityIndicator.stopAnimating()
                loadingView.isHidden = true
            }
        }
    }
    
    //Gradiently changing colors from red to green (Int values)
    fileprivate let colorsInt = [
        (217, 30, 24),
        (246, 71, 71),
        (242, 120, 75),
        (249, 105, 14),
        (243, 156, 18),
        (247, 202, 24),
        (180, 220, 37),
        (153, 180, 51),
        (135, 211, 124),
        (102, 204, 102)
    ]
    
    fileprivate func color(index: Int) -> UIColor {
        
        //If there is an error - return green
        guard index >= 0 && index < colorsInt.count else {
            return UIColor(red: CGFloat(colorsInt[colorsInt.count - 1].0)/255.0, 
                           green: CGFloat(colorsInt[colorsInt.count - 1].1)/255.0, 
                           blue: CGFloat(colorsInt[colorsInt.count - 1].2)/255.0, 
                           alpha: 1)
        }
        
        return UIColor(red: CGFloat(colorsInt[index].0)/255.0, 
                       green: CGFloat(colorsInt[index].1)/255.0, 
                       blue: CGFloat(colorsInt[index].2)/255.0, 
                       alpha: 1)
    }
    
    
    fileprivate func dayLocalizableFor(daysCnt: Int) -> String {
        switch (daysCnt % 10) {
        case 1: return NSLocalizedString("days1", comment: "")
        case 2, 3, 4: return NSLocalizedString("days234", comment: "")
        default: return NSLocalizedString("days567890", comment: "")
        }
    }
    
    fileprivate func initialize() {
        currentStreakLabel.text = NSLocalizedString("CurrentStreakTitle", comment: "")
        currentStreakDaysInARowLabel.text = "\(dayLocalizableFor(daysCnt: currentStreak)) \(NSLocalizedString("InARow", comment: ""))"
        bestStreakLabel.text = NSLocalizedString("LongestStreak", comment: "")
        bestStreakDaysInARowLabel.text = dayLocalizableFor(daysCnt: bestStreak)
        bestStreakCountLabel.textColor = color(index: colorsInt.count - 1)
    }
    
    func setStreaks(current: Int, best: Int) {
        bestStreak = best
        currentStreak = current
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
        let nib = UINib(nibName: "StreaksView", bundle: bundle)
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

    
}
