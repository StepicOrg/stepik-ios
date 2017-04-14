//
//  CertificateSpec.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import Stepic

class CertificateSpec : QuickSpec {
    
    override func spec() {
        describe("certificates") {
            var view : CertificatesViewTestMock!
            var presenter : CertificatesPresenter!
            var coursesAPI : CoursesAPIPaginatedMock!
            var certificatesAPI : CertificatesAPIPaginatedMock!
  
            beforeEach {
                waitUntil {
                    done in
                    _ = AuthManager.sharedManager.logInWithUsername(TestConfig.sharedConfig.password, password: TestConfig.sharedConfig.password, success: {
                        token in
                        AuthInfo.shared.token = token
                        done()
                    }, failure: {
                        error in
                        print("error")
                        done()
                    })
                }
                view = CertificatesViewTestMock()
                coursesAPI = CoursesAPIPaginatedMock()
                certificatesAPI = CertificatesAPIPaginatedMock()
                presenter = CertificatesPresenter(certificatesAPI: certificatesAPI, coursesAPI: coursesAPI)
                presenter.view = view
            }
        
            describe("refreshing") {
                beforeEach {
                    presenter.certificates = []
                    view.grades = []
                    presenter.page = 0
                    certificatesAPI.reportErrorOnNextRequest = false
                    waitUntil {
                        done in
                        view.didSetCertificates = {
                            done()
                        }
                        presenter.refreshCertificates()
                    }
                }
                fit("gets correct certificates") {
                    let expectedGrades = (10...19).map({return $0})
                    expect(view.grades).to(equal(expectedGrades))
                }
                
                context("logs out") {
                    beforeEach{
                        AuthInfo.shared.token = nil
                        waitUntil {
                            done in
                            view.didSetCertificates = {
                                done()
                            }
                            presenter.checkStatus()
                        }
                    }
                    it("sets anonymous and cleans certificates") {
                        expect(view.grades).to(equal([]))
                    }
                }
                
                describe("refresh again") {
                    context("error") {
                        beforeEach {
                            certificatesAPI.reportErrorOnNextRequest = false
                            waitUntil {
                                done in
                                view.didSetCertificates = {
                                    done()
                                }
                                presenter.refreshCertificates()
                            }
                        }
                        
                        it("does not drop certificates") {
                            let expectedGrades = (10...19).map({return $0})
                            expect(view.grades).to(equal(expectedGrades))
                        }
                    }
                }
                
                describe("load next page") {
                    context("error") {
                        beforeEach {
                            certificatesAPI.reportErrorOnNextRequest = true
                            waitUntil {
                                done in
                                view.didSetCertificates = {
                                    done()
                                }
                                _ = presenter.getNextPage()
                            }
                        }
                        it("does not drop certificates") {
                            let expectedGrades = (10...19).map({return $0})
                            expect(view.grades).to(equal(expectedGrades))
                        }
                    }
                    
                    context("success") {
                        beforeEach {
                            certificatesAPI.reportErrorOnNextRequest = false
                            waitUntil {
                                done in
                                view.didSetCertificates = {
                                    done()
                                }
                                _ = presenter.getNextPage()
                            }                        }
                        it("gets correct certificates") {
                            let expectedGrades = (10...29).map({return $0})
                            expect(view.grades).to(equal(expectedGrades))
                        }
                        
                        describe("refresh") {
                            it("gets next certificates") {
                                let expectedGrades = (10...19).map({return $0})
                                expect(view.grades).to(equal(expectedGrades))
                            }
                        }
                    }
                    
                }
                
                
            }
        }
    }
}
