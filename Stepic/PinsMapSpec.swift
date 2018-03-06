//
//  PinsMapSpec.swift
//  StepicTests
//
//  Created by Vladislav Kiryukhin on 05.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Quick
import Nimble

@testable import Stepic

class PinsMapSpec: QuickSpec {
    override func spec() {
        // sampleWeeks => sampleDays
        let sampleWeeks = [
            PinsMap.Week(allowedPins: [false, false, false, false, true, true, true], pins: [0, 0, 0, 0, 5, 3, 2]),
            PinsMap.Week(allowedPins: [true, true, true, true, true, true, false], pins: [1, 2, 1, 0, 1, 1, 0])
        ]
        let sampleDays: [(Bool, Int)] = sampleWeeks.map { zip($0.allowedPins, $0.pins) }.reduce([], +)

        describe("PinsMap Month") {
            var month: PinsMap.Month!

            beforeEach {
                month = PinsMap.Month(weeks: sampleWeeks)
            }

            context("when initialized with weeks:") {
                it("has correct weeks") {
                    expect(month.weeks) == sampleWeeks
                }
                it("has correct days") {
                    let l1 = month.days.map { $0.0 }
                    let r1 = sampleDays.map { $0.0 }
                    let l2 = month.days.map { $0.1 }
                    let r2 = sampleDays.map { $0.1 }
                    expect(l1) == r1
                    expect(l2) == r2
                }
            }

            context("when shifted") {
                context("with offset == 1 (first weekday is Sunday)") {
                    it("has no changes") {
                        let shiftedMonth = month.shifted(firstWeekDay: 1)
                        expect(shiftedMonth.weeks) == month.weeks
                    }
                }

                context("with offset == 2 (first weekday is Monday)") {
                    it("has correct shifts in both pins arrays") {
                        let shiftedMonth = month.shifted(firstWeekDay: 2)
                        expect(shiftedMonth.weeks[0].allowedPins) == [false, false, false, true, true, true, false]
                        expect(shiftedMonth.weeks[0].pins) == [0, 0, 0, 5, 3, 2, 0]
                    }
                }
            }

            context("when trimmed") {
                context("0 days") {
                    it("has no changes") {
                        let trimmedMonth = month.trimmed(daysCount: 0)
                        expect(trimmedMonth.weeks[0].allowedPins) == [false, false, false, false, false, false, false]
                    }
                }
                context("1 day") {
                    it("has correct pins") {
                        let trimmedMonth = month.trimmed(daysCount: 1)
                        expect(trimmedMonth.weeks[0].allowedPins) == [false, false, false, false, true, false, false]
                    }
                }
                context("4 days") {
                    it("has correct pins") {
                        let trimmedMonth = month.trimmed(daysCount: 4)
                        expect(trimmedMonth.weeks[0].allowedPins) == [false, false, false, false, true, true, true]
                        expect(trimmedMonth.weeks[1].allowedPins) == [true, false, false, false, false, false, false]
                    }
                }
                context("all days") {
                    it("has correct pins") {
                        let trimmedMonth = month.trimmed(daysCount: 14)
                        expect(trimmedMonth.weeks[0].allowedPins) == [false, false, false, false, true, true, true]
                        expect(trimmedMonth.weeks[1].allowedPins) == [true, true, true, true, true, true, false]
                    }
                }
            }

            context("when filled") {
                context("empty pins") {
                    it("has no changes") {
                        let filledMonth = month.filled(pins: [])
                        expect(filledMonth.weeks[0].allowedPins) == sampleWeeks[0].allowedPins
                        expect(filledMonth.weeks[0].pins) == sampleWeeks[0].pins
                    }
                }
                context("non-empty pins") {
                    it("has correct pins") {
                        let pins = (1...14).map { Int($0) }
                        let filledMonth = month.filled(pins: pins)
                        expect(filledMonth.weeks[0].allowedPins) == sampleWeeks[0].allowedPins
                        expect(filledMonth.weeks[1].allowedPins) == sampleWeeks[1].allowedPins
                        expect(Array(filledMonth.weeks[0].pins.dropFirst(4))) == [1, 2, 3]
                        expect(Array(filledMonth.weeks[1].pins.dropLast(1))) == [4, 5, 6, 7, 8, 9]
                    }
                }
            }
        }

        describe("PinsMap") {
            context("when built month") {
                var map: PinsMap!

                let checkIsGivenEqualToReal: (Int, Int, Date?, Int, [Bool], [Bool]) -> Void = { year, month, lastDay, realWeekCount, firstWeek, lastWeek -> Void in
                    var m: PinsMap.Month!
                    if let lastDay = lastDay {
                        expect { m = try map.buildMonth(year: year, month: month, lastDay: lastDay) }.toNot(throwError())
                    } else {
                        expect { m = try map.buildMonth(year: year, month: month) }.toNot(throwError())
                    }
                    expect(m.weeks.count) == realWeekCount
                    expect(m.weeks.first?.allowedPins) == firstWeek
                    expect(m.weeks.last?.allowedPins) == lastWeek
                }

                context("when first weekday is Sunday") {
                    beforeEach {
                        var calendar = Calendar.current
                        calendar.firstWeekday = 1
                        map = PinsMap(calendar: calendar)
                    }

                    context("with real data (2017-01)") {
                        it("is not throw exception and has correct weeks") {
                            checkIsGivenEqualToReal(2017, 1, nil, 5, [true, true, true, true, true, true, true], [true, true, true, false, false, false, false])
                        }
                    }
                    context("with real data (2017-12)") {
                        it("is not throw exception and has correct weeks") {
                            checkIsGivenEqualToReal(2017, 12, nil, 6, [false, false, false, false, false, true, true], [true, false, false, false, false, false, false])
                        }
                    }
                    context("with real data (2018-02) and trim day (2018-02-02)") {
                        it("is not throw exception and has correct weeks") {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd"
                            formatter.timeZone = TimeZone(abbreviation: "UTC")!
                            let day_02_02_2018 = formatter.date(from: "2018/02/02")
                            checkIsGivenEqualToReal(2018, 2, day_02_02_2018, 5, [false, false, false, false, true, true, false], [false, false, false, false, false, false, false])
                        }
                    }
                }

                context("when first weekday is Monday") {
                    beforeEach {
                        var calendar = Calendar.current
                        calendar.firstWeekday = 2
                        map = PinsMap(calendar: calendar)
                    }

                    context("with real data (2017-01)") {
                        it("is not throw exception and has correct weeks") {
                            checkIsGivenEqualToReal(2017, 1, nil, 6, [false, false, false, false, false, false, true], [true, true, false, false, false, false, false])
                        }
                    }
                    context("with real data (2017-12)") {
                        it("is not throw exception and has correct weeks") {
                            checkIsGivenEqualToReal(2017, 12, nil, 5, [false, false, false, false, true, true, true], [true, true, true, true, true, true, true])
                        }
                    }
                    context("with real data (2018-02) and trim day (2018-02-02)") {
                        it("is not throw exception and has correct weeks") {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy/MM/dd"
                            formatter.timeZone = TimeZone(abbreviation: "UTC")!
                            let day_02_02_2018 = formatter.date(from: "2018/02/02")
                            checkIsGivenEqualToReal(2018, 2, day_02_02_2018, 5, [false, false, false, true, true, false, false], [false, false, false, false, false, false, false])
                        }
                    }
                }
            }
        }
    }
}
