//
//  AbstractGraphBuilder.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol AbstractGraphBuilder {
    associatedtype T: Hashable
    func build() -> AbstractGraph<T>
}
