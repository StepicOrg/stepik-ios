//
//  CertificatesViewTestMock.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CertificatesViewTestMock: CertificatesView {

    var grades: [Int] = []
    var presenter: CertificatesPresenter!

    func setCertificates(certificates: [CertificateViewData], hasNextPage: Bool) {
        grades = certificates.map {
            $0.grade
        }
        didSetCertificates?()
    }

    var didSetCertificates : (() -> Void)?

    func displayAnonymous() {
    }

    func displayError() {
    }

    func displayEmpty() {
    }

    func displayRefreshing() {
    }

    func displayLoadNextPageError() {
    }

    func updateData() {
    }

}
