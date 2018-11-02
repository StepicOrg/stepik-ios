//
//  CourseInfoInstructorBlockView.swift
//  Stepic
//
//  Created by Ivan Magda on 11/1/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension CourseInfoInstructorsBlockView {
    struct Appearance {
        let headerViewInsets = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 36)
        
        let stackViewInsets = UIEdgeInsets(top: 12, left: 36, bottom: 0, right: 36)
    }
}

final class CourseInfoInstructorsBlockView: UIView {
    private let appearance: Appearance
    
    private lazy var headerView: CourseInfoBlockView = {
        CourseInfoBlockView(frame: .zero)
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        viewModel: CourseInfoInstructorsBlockViewModel
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
        
        self.configure(with: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(with viewModel: CourseInfoInstructorsBlockViewModel) {
        self.headerView.configure(with: viewModel)
        
        viewModel.instructors.forEach { instructor in
            self.stackView.addArrangedSubview(
                CourseInfoInstructorView(viewModel: instructor)
            )
        }
    }
}

extension CourseInfoInstructorsBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.headerView)
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.headerView.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.snp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview().inset(self.appearance.headerViewInsets)
        }
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(self.appearance.stackViewInsets)
            make.top.equalTo(self.headerView.snp.bottom).offset(self.appearance.stackViewInsets.top)
        }
    }
}
