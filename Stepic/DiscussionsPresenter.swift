//
//  DiscussionsPresenter.swift
//  Stepic
//
//  Created by Ivan Magda on 7/4/19.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol DiscussionsView: class {
}

protocol DiscussionsPresenterProtocol: class {
}


final class DiscussionsPresenter: DiscussionsPresenterProtocol {
    weak var view: DiscussionsView?
}
