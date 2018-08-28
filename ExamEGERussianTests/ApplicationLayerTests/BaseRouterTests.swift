//
//  BaseRouterTests.swift
//  ExamEGERussianTests
//
//  Created by Ivan Magda on 16/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import XCTest
@testable import ExamEGERussian

class BaseRouterTests: XCTestCase {
    var router: BaseRouter!
    var navigationController: UINavigationController!
    var window: UIWindow!

    override func setUp() {
        super.setUp()

        navigationController = MockAssemblyNavigationController()
        router = BaseRouter(
            assemblyFactory: AssemblyFactoryMock(),
            navigationController: navigationController
        )

        window = UIWindow()
        window.makeKeyAndVisible()
    }

    override func tearDown() {
        super.tearDown()

        navigationController = nil
        router = nil
        window = nil
    }

    func testBaseRouterNavigationControllerCreated() {
        XCTAssertNotNil(router.navigationController)
    }

    func testBaseRouterAssemblyFactoryType() {
        XCTAssert(router.assemblyFactory is AssemblyFactoryMock)
    }

    func testBaseRouterPushViewController() {
        router.pushViewController(derivedFrom: { _ in
            MockAssemblyViewController()
        }, animated: false)

        XCTAssertEqual(router.navigationController!.viewControllers.count, 1)
        XCTAssert(router.navigationController!.viewControllers.first! is MockAssemblyViewController)
    }

    func testBaseRouterPushViewControllerOnNilNavigationController() {
        navigationController = nil
        let viewControllerToPresent = MockAssemblyViewController()

        router.pushViewController(derivedFrom: { _ in
            XCTFail("Shouldn't happen, `navigationController` must be deallocated.")
            return viewControllerToPresent
        }, animated: false)

        XCTAssertNil(viewControllerToPresent.presentingViewController)
        XCTAssertNil(router.navigationController)
    }

    func testBaseRouterPresentModalNavigationController() {
        window.rootViewController = navigationController
        let viewControllerToPresent = MockAssemblyViewController()

        router.presentModalNavigationController(derivedFrom: { _ in
            viewControllerToPresent
        }, animated: false)

        XCTAssert(viewControllerToPresent.presentingViewController! === router.navigationController!)
    }

    func testBaseRouterPresentModalNavigationControllerOnNilNavigationController() {
        navigationController = nil
        let viewControllerToPresent = MockAssemblyViewController()

        router.presentModalNavigationController(derivedFrom: { _ in
            XCTFail("Shouldn't happen, `navigationController` must be deallocated.")
            return viewControllerToPresent
        }, animated: false)

        XCTAssertNil(viewControllerToPresent.presentingViewController)
        XCTAssertNil(router.navigationController)
    }

    func testBaseRouterDismissModallyPresentedViewController() {
        let ex = expectation(description: "\(#function)")

        let navigationController = MockAssemblyNavigationController()
        let router = BaseRouter(
            assemblyFactory: AssemblyFactoryMock(),
            navigationController: navigationController
        )

        let window = UIWindow()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        let viewControllerToPresent = MockAssemblyViewController()

        router.presentModalNavigationController(derivedFrom: { _ in
            viewControllerToPresent
        }, animated: false)
        XCTAssert(window.topMostWindowController() === viewControllerToPresent)

        router.dismiss(animated: false, completion: {
            XCTAssert(window.topMostWindowController() === navigationController)
            ex.fulfill()
        })

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testBaseRouterPopViewControllerFromNavigationStack() {
        let mockViewController = MockAssemblyViewController()

        router.pushViewController(derivedFrom: { _ in
            mockViewController
        }, animated: false)
        router.pushViewController(derivedFrom: { _ in
            UIViewController()
        }, animated: false)

        XCTAssert(router.navigationController!.viewControllers.count == 2)
        router.pop(animated: false)

        XCTAssert(router.navigationController!.viewControllers.count == 1)
        XCTAssert(router.navigationController!.viewControllers.first === mockViewController)
    }

    func testBaseRouterPopToRootViewController() {
        let rootViewController = UIViewController()

        router.navigationController?.setViewControllers(
            [rootViewController, UIViewController(), MockAssemblyViewController()],
            animated: false
        )
        router.popToRootViewController(animated: false)
        XCTAssert(router.navigationController!.topViewController === rootViewController)
    }

    func testBaseRouterPopToViewController() {
        let rootViewController = MockAssemblyViewController()
        let viewControllerToPop = UIViewController()

        router.navigationController?.setViewControllers(
            [rootViewController, viewControllerToPop, MockAssemblyViewController()],
            animated: false
        )
        router.popToViewController(viewControllerToPop, animated: false)

        XCTAssert(router.navigationController!.topViewController === viewControllerToPop)
        XCTAssert(router.navigationController!.viewControllers.first === rootViewController)
    }
}
