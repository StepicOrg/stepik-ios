//
//  CatalogView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 12.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CatalogView: class {

    func notifyNotAuthorized()

    func provide(userCourses: UserCourses)
}

protocol DetailCatalogView: class {

    func updateDetailView()

}
