//
//  CertificatesView.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol CertificatesView: AnyObject {
    func setCertificates(certificates: [CertificateViewData], hasNextPage: Bool)

    func displayError()
    func displayEmpty()
    func displayRefreshing()
    func displayLoadNextPageError()
}
