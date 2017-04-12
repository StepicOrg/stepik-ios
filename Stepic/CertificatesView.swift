//
//  CertificatesView.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol CertificatesView: class {
    func setCertificates(certificates: [CertificateViewData], hasNextPage: Bool)
    func displayAnonymous()
    func displayError()
    func displayLoadNextPageError()
    func updateData()
}
