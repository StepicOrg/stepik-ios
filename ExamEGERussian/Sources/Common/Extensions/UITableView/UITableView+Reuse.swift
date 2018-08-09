//
//  UITableView+Reuse.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit.UITableView

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let identifier = T.identifier
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T // swiftlint:disable:this force_cast
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        let identifier = T.identifier
        return dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T // swiftlint:disable:this force_cast
    }
}
