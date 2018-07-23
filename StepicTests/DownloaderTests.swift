//
//  DownloaderTests.swift
//  StepicTests
//
//  Created by Vladislav Kiryukhin on 11.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Nimble
import Quick
import XCTest
import Mockingjay

@testable import Stepic

class DownloaderTaskMock: DownloaderTask {
    var isCompleted = false

    // In this tests we run Downloader's methods directly
    // So task is detached and we should manually update its state
    var _state: DownloaderTaskState = .detached
    var customStateReporter: ((DownloaderTaskState) -> Void)?

    override var stateReporter: ((DownloaderTaskState) -> Void)? {
        get {
            return { newState in
                self._state = newState
                self.customStateReporter?(newState)
            }
        }
        set {
            self.customStateReporter = newValue
        }
    }

    override var state: DownloaderTaskState {
        return _state
    }
}

class DownloaderSpec: QuickSpec {
    private static let okFileLink = "https://fake.fake/ok.json"
    private static let fileWithExpectedSizeLink = "https://fake.fake/size.json"
    private static let notFoundLink = "https://fake.fake/notfound.json"

    private static let fileSizeInBytes: UInt64 = 1024
    private static let fileChunksCount = 5

    var downloader: Downloader!

    private func isFileExists(url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }

    private func getFileSize(url: URL) -> UInt64? {
        return (try? FileManager.default.attributesOfItem(atPath: url.path))?[FileAttributeKey.size] as? UInt64
    }

    private func jsonDataWithExpectedSizeHeader(data: Data, chunksCount: Int) -> ((_ request: URLRequest) -> Response) {
        return { (request: URLRequest) in
            let headers = [
                "Content-Length": "\(data.count)"
            ]

            return http(200, headers: headers, download: .streamContent(data: data, inChunksOf: chunksCount))(request)
        }
    }

    private func jsonDataWithEmptySizeHeader(data: Data, chunksCount: Int) -> ((_ request: URLRequest) -> Response) {
        return { (request: URLRequest) in
            return http(200, headers: [String: String](), download: .streamContent(data: data, inChunksOf: chunksCount))(request)
        }
    }

    private func setUpNetworkStub() {
        Nimble.AsyncDefaults.Timeout = 60
        Nimble.AsyncDefaults.PollInterval = 0.05

        self.stub(uri(DownloaderSpec.okFileLink), self.jsonDataWithEmptySizeHeader(
            data: Data(count: Int(DownloaderSpec.fileSizeInBytes)),
            chunksCount: DownloaderSpec.fileChunksCount
        ))
        self.stub(uri(DownloaderSpec.fileWithExpectedSizeLink), self.jsonDataWithExpectedSizeHeader(
            data: Data(count: Int(DownloaderSpec.fileSizeInBytes)),
            chunksCount: DownloaderSpec.fileChunksCount
        ))
        self.stub(uri(DownloaderSpec.notFoundLink), http(404))
    }

    override func spec() {
        describe("Downloader") {

            context("when task with correct url and without size in headers executed in downloader") {
                var task: DownloaderTaskMock!

                beforeEach {
                    self.setUpNetworkStub()
                    self.downloader = Downloader(session: .foreground)
                    task = DownloaderTaskMock(url: URL(string: DownloaderSpec.okFileLink)!)
                }

                it("reports about completion with correct file") {
                    waitUntil { done in
                        task.completionReporter = { url in
                            expect(self.isFileExists(url: url)) == true
                            expect(self.getFileSize(url: url)) == DownloaderSpec.fileSizeInBytes

                            done()
                        }

                        task.failureReporter = { _ in
                            fail("task should finish correctly")

                            done()
                        }

                        expect { try self.downloader.add(task: task) }.notTo(throwError())
                        expect { try self.downloader.resume(task: task) }.notTo(throwError())
                    }
                }

                it("reports nil progress") {
                    waitUntil { done in
                        task.progressReporter = { progress in
                            expect(progress).to(beNil())
                        }

                        task.failureReporter = { _ in
                            fail("task should finish correctly")

                            done()
                        }

                        task.completionReporter = { _ in done() }

                        expect { try self.downloader.add(task: task) }.notTo(throwError())
                        expect { try self.downloader.resume(task: task) }.notTo(throwError())
                    }
                }
            }

            context("when task with 404 url executed in downloader") {
                var task: DownloaderTaskMock!

                beforeEach {
                    self.setUpNetworkStub()
                    task = DownloaderTaskMock(url: URL(string: "http://httpstat.us/404")!)
                }

                it("cancels task with error") {
                    waitUntil { done in
                        task.failureReporter = { error in
                            expect(task.state) == .stopped
                            if case DownloaderError.serverSide(_) = error { } else {
                                fail("after server side error reported wrong error")
                            }

                            done()
                        }

                        task.completionReporter = { url in
                            fail("completion reporter shouldn't be called")

                            done()
                        }

                        expect { try self.downloader.add(task: task) }.notTo(throwError())
                        expect { try self.downloader.resume(task: task) }.notTo(throwError())
                    }
                }
            }

            context("when task with correct url and with size in headers executed in downloader") {
                var task: DownloaderTaskMock!

                beforeEach {
                    self.setUpNetworkStub()
                    task = DownloaderTaskMock(url: URL(string: DownloaderSpec.fileWithExpectedSizeLink)!)
                }

                it("reports correct progress") {
                    var progresses = [Float]()
                    waitUntil { done in
                        task.progressReporter = { progress in
                            expect(progress).notTo(beNil())
                            expect(progress!) >= 0.0
                            expect(progress!) <= 1.0

                            progresses += [progress!]
                        }

                        task.failureReporter = { _ in
                            fail("task should finish correctly")

                            done()
                        }

                        task.completionReporter = { _ in
                            // Each next progress value should be greater then values before
                            expect(progresses) == progresses.sorted()
                            done()
                        }

                        expect { try self.downloader.add(task: task) }.notTo(throwError())
                        expect { try self.downloader.resume(task: task) }.notTo(throwError())
                    }
                }

                context("when pause called") {
                    beforeEach {
                        self.setUpNetworkStub()
                        self.downloader = Downloader(session: .foreground)
                    }

                    it("pauses given task") {
                        var didPauseCall = false
                        var states = [DownloaderTaskState]()
                        let lock = NSLock()
                        task.progressReporter = { progress in
                            // Some trick: pause task from first call of progress reporter
                            if !didPauseCall {
                                expect { try self.downloader.pause(task: task) }.notTo(throwError())
                                didPauseCall = true
                                lock.unlock()
                            }
                        }
                        task.stateReporter = { newState in
                            states.append(newState)
                        }
                        task.failureReporter = { _ in
                            fail("task should finish correctly")
                            lock.unlock()
                        }

                        waitUntil { done in
                            task.completionReporter = { url in
                                // Check states history
                                expect(states) == [DownloaderTaskState.attached, DownloaderTaskState.active, DownloaderTaskState.paused, DownloaderTaskState.active]
                                done()
                            }

                            lock.lock()
                            expect { try self.downloader.add(task: task) }.notTo(throwError())
                            expect { try self.downloader.resume(task: task) }.notTo(throwError())
                            lock.lock()
                            expect { try self.downloader.resume(task: task) }.notTo(throwError())
                        }
                    }
                }

                context("when cancel called") {
                    beforeEach {
                        self.setUpNetworkStub()
                        self.downloader = Downloader(session: .foreground)
                    }

                    it("makes task unresumable") {
                        var states = [DownloaderTaskState]()
                        waitUntil { done in
                            task.stateReporter = { state in
                                states += [state]
                                if state == .detached {
                                    // Task should have state == .detached (not .stopped)
                                    expect(states) == [DownloaderTaskState.attached, DownloaderTaskState.active, DownloaderTaskState.stopped, DownloaderTaskState.detached]
                                    done()
                                }
                            }

                            var didCancelCall = false
                            task.progressReporter = { progress in
                                if !didCancelCall {
                                    expect { try self.downloader.cancel(task: task) }.notTo(throwError())
                                    didCancelCall = true
                                }
                            }

                            task.failureReporter = { _ in
                                fail("task should finish correctly")

                                done()
                            }

                            task.completionReporter = { url in
                                fail("completion reporter shouldn't be called")

                                done()
                            }

                            expect { try self.downloader.add(task: task) }.notTo(throwError())
                            expect { try self.downloader.resume(task: task) }.notTo(throwError())
                        }
                    }
                }
            }

            context("when multiple tasks executed in downloader simultaneously") {
                beforeEach {
                    self.setUpNetworkStub()
                    self.downloader = Downloader(session: .foreground)
                }

                it("finish all tasks correctly") {
                    let group = DispatchGroup()
                    let queue = DispatchQueue.global(qos: .default)

                    let tasks: [DownloaderTaskMock] = (0...5).map { _ in
                        DownloaderTaskMock(url: URL(string: DownloaderSpec.fileWithExpectedSizeLink)!)
                    }

                    // Run all tasks simultaneously
                    for task in tasks {
                        task.completionReporter = { _ in
                            task.isCompleted = true
                            group.leave()
                        }

                        group.enter()
                        expect { try self.downloader.add(task: task) }.notTo(throwError())
                        expect { try self.downloader.resume(task: task) }.notTo(throwError())
                    }

                    waitUntil { done in
                        group.notify(queue: queue) {
                            for task in tasks {
                                if task.state != .detached || !task.isCompleted {
                                    fail("after execution task has invalid state = \(task.state), isCompleted = \(task.isCompleted)")
                                }
                            }

                            done()
                        }
                    }
                }
            }

            context("when try to resume detached task in downloader") {
                var task: DownloaderTaskMock!

                beforeEach {
                    self.setUpNetworkStub()
                    task = DownloaderTaskMock(url: URL(string: DownloaderSpec.fileWithExpectedSizeLink)!)
                    self.downloader = Downloader(session: .foreground)
                }

                it("throws error") {
                    expect { try self.downloader.resume(task: task) }.to(throwError())
                }
            }
        }
    }
}
