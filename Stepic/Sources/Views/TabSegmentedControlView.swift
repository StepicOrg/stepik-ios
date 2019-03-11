//
//  TabSegmentedControlView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.11.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

protocol TabSegmentedControlViewDelegate: class {
    func tabSegmentedControlView(
        _ tabSegmentedControlView: TabSegmentedControlView,
        didSelectTabWithIndex: Int
    )
}

extension TabSegmentedControlView {
    struct Appearance {
        let backgroundColor = UIColor(hex: 0xf6f6f6)

        let buttonInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let buttonTitleFontNormal = UIFont.systemFont(ofSize: 15, weight: .light)
        let buttonTitleFontSelected = UIFont.systemFont(ofSize: 15)
        let buttonTitleColor = UIColor.mainDark

        let bottomBorderColor = UIColor(hex: 0x9b9b9b)
        let bottomBorderHeight: CGFloat = 0.5

        let bottomSelectedMarkerColor = UIColor.mainDark
        let bottomSelectedMarkerHeight: CGFloat = 2.7
    }
}

final class TabSegmentedControlView: UIView {
    enum Animation {
        static let duration: TimeInterval = 0.25
    }

    weak var delegate: TabSegmentedControlViewDelegate?

    let appearance: Appearance
    private let items: [String]
    private var tabButtons: [TabButton] = []
    private var selectedItemIndex: Int = 0

    private lazy var bottomSelectedMarkerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = self.appearance.bottomSelectedMarkerColor
        return view
    }()

    private lazy var bottomBorderView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = self.appearance.bottomBorderColor
        return view
    }()

    private lazy var scrollableStackView: ScrollableStackView = {
        let stackView = ScrollableStackView(frame: .zero, orientation: .horizontal)
        stackView.shouldBounce = false
        stackView.showsHorizontalScrollIndicator = false
        return stackView
    }()

    init(frame: CGRect, items: [String], appearance: Appearance = Appearance()) {
        self.appearance = appearance
        self.items = items
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()

        self.initItems()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateSelectedMarker()
    }

    func selectTab(index: Int) {
        guard index >= 0,
              index < self.items.count else {
            return
        }

        self.selectedItemIndex = index
        if let selectedButton = self.tabButtons[safe: self.selectedItemIndex] {
            self.tabButtonClicked(selectedButton)
        }
    }

    private func initItems() {
        for (index, item) in self.items.enumerated() {
            let button = self.makeTabButton(title: item)
            button.isSelected = index == self.selectedItemIndex
            button.addTarget(self, action: #selector(self.tabButtonClicked(_:)), for: .touchUpInside)

            self.scrollableStackView.addArrangedView(button)
            self.tabButtons.append(button)
        }
    }

    private func updateSelectedMarker(animated: Bool = false) {
        guard let selectedButton = self.tabButtons[safe: self.selectedItemIndex] else {
            return
        }

        if animated {
            self.layoutIfNeeded()
        }

        let selectedFrame = selectedButton.textFrame
        self.bottomSelectedMarkerView.snp.updateConstraints { make in
            make.width.equalTo(selectedFrame.width)
            make.leading.equalTo(selectedButton.frame.origin.x + selectedFrame.origin.x)
        }

        if animated {
            UIView.animate(withDuration: Animation.duration) {
                self.layoutIfNeeded()
            }
        }
    }

    private func makeTabButton(title: String) -> TabButton {
        let button = TabButton()
        button.contentEdgeInsets = self.appearance.buttonInsets

        button.selectedStateFont = self.appearance.buttonTitleFontSelected
        button.normalStateFont = self.appearance.buttonTitleFontNormal

        button.setTitleColor(self.appearance.buttonTitleColor, for: .normal)
        button.setTitle(title, for: .normal)
        return button
    }

    @objc
    private func tabButtonClicked(_ sender: TabButton) {
        for (index, button) in self.tabButtons.enumerated() {
            if button === sender {
                button.isSelected = true
                self.selectedItemIndex = index
            } else {
                button.isSelected = false
            }
        }
        self.updateSelectedMarker(animated: true)

        self.delegate?.tabSegmentedControlView(self, didSelectTabWithIndex: self.selectedItemIndex)
    }
}

extension TabSegmentedControlView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.scrollableStackView)
        self.addSubview(self.bottomBorderView)
        self.addSubview(self.bottomSelectedMarkerView)
    }

    func makeConstraints() {
        self.scrollableStackView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollableStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomBorderView.snp.makeConstraints { make in
            make.bottom.equalTo(self.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(self.appearance.bottomBorderHeight)
        }

        self.bottomSelectedMarkerView.translatesAutoresizingMaskIntoConstraints = false
        self.bottomSelectedMarkerView.snp.makeConstraints { make in
            make.width.equalTo(10)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalTo(self.snp.bottom)
            make.height.equalTo(self.appearance.bottomSelectedMarkerHeight)
        }
    }
}

// MARK: - TabButton

private final class TabButton: UIButton {
    var normalStateFont: UIFont?
    var selectedStateFont: UIFont?

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.2 : 1.0
        }
    }

    /// Frame of text label. Used for black underline when selected
    var textFrame: CGRect {
        return self.titleLabel?.frame ?? self.frame
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        switch self.state {
        case .selected:
            if let font = self.selectedStateFont {
                self.titleLabel?.font = font
            }
        default:
            if let font = self.normalStateFont {
                self.titleLabel?.font = font
            }
        }
    }
}
