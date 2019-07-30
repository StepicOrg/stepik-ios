//
//  AchievementDescription.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum AchievementKind: String {
    // Cases should be declared in correct order,
    // cause getBadge method uses hashValue
    case stepsSolved = "steps_solved"
    case stepsSolvedStreak = "steps_solved_streak"
    case stepsSolvedChoice = "steps_solved_choice"
    case stepsSolvedCode = "steps_solved_code"
    case stepsSolvedNumber = "steps_solved_number"
    case codeQuizzesSolvedPython = "code_quizzes_solved_python"
    case codeQuizzesSolvedCPP = "code_quizzes_solved_cpp"
    case codeQuizzesSolvedJava = "code_quizzes_solved_java"
    case activeDaysStreak = "active_days_streak"
    case certificatesRegularCount = "certificates_regular_count"
    case certificatesDistinctionCount = "certificates_distinction_count"
    case courseReviewsCount = "course_reviews_count"

    func getBadge(for level: Int) -> UIImage {
        return UIImage(named: "achievement-\(imageID)-\(level)") ?? #imageLiteral(resourceName: "achievement-0")
    }

    var imageID: Int {
        switch self {
        case .stepsSolved:
            return 1
        case .stepsSolvedStreak:
            return 2
        case .stepsSolvedChoice:
            return 3
        case .stepsSolvedCode:
            return 4
        case .stepsSolvedNumber:
            return 5
        case .codeQuizzesSolvedPython:
            return 6
        case .codeQuizzesSolvedCPP:
            return 7
        case .codeQuizzesSolvedJava:
            return 8
        case .activeDaysStreak:
            return 9
        case .certificatesRegularCount:
            return 10
        case .certificatesDistinctionCount:
            return 11
        case .courseReviewsCount:
            return 12
        }
    }

    func getName() -> String {
        switch self {
        case .stepsSolved:
            return NSLocalizedString("AchievementsStepsSolvedKindTitle", comment: "")
        case .stepsSolvedChoice:
            return NSLocalizedString("AchievementsStepsSolvedChoiceKindTitle", comment: "")
        case .stepsSolvedCode:
            return NSLocalizedString("AchievementsStepsSolvedCodeKindTitle", comment: "")
        case .stepsSolvedNumber:
            return NSLocalizedString("AchievementsStepsSolvedNumberKindTitle", comment: "")
        case .codeQuizzesSolvedPython:
            return NSLocalizedString("AchievementsCodeQuizzesSolvedPythonKindTitle", comment: "")
        case .codeQuizzesSolvedJava:
            return NSLocalizedString("AchievementsCodeQuizzesSolvedJavaKindTitle", comment: "")
        case .codeQuizzesSolvedCPP:
            return NSLocalizedString("AchievementsCodeQuizzesSolvedCppKindTitle", comment: "")
        case .certificatesRegularCount:
            return NSLocalizedString("AchievementsCertificatesRegularCountKindTitle", comment: "")
        case .certificatesDistinctionCount:
            return NSLocalizedString("AchievementsCertificatesDistinctionCountKindTitle", comment: "")
        case .courseReviewsCount:
            return NSLocalizedString("AchievementsCourseReviewsCountKindTitle", comment: "")
        case .stepsSolvedStreak:
            return NSLocalizedString("AchievementsStepsSolvedStreakKindTitle", comment: "")
        case .activeDaysStreak:
            return NSLocalizedString("AchievementsActiveDaysStreakKindTitle", comment: "")
        }
    }

    func getDescription(for score: Int) -> String {
        let forms: [String] = {
            switch self {
            case .stepsSolved:
                return [
                    NSLocalizedString("AchievementsStepsSolvedKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedKindDescription567890", comment: "")
                ]
            case .stepsSolvedChoice:
                return [
                    NSLocalizedString("AchievementsStepsSolvedChoiceKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedChoiceKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedChoiceKindDescription567890", comment: "")
                ]
            case .stepsSolvedCode:
                return [
                    NSLocalizedString("AchievementsStepsSolvedCodeKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedCodeKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedCodeKindDescription567890", comment: "")
                ]
            case .stepsSolvedNumber:
                return [
                    NSLocalizedString("AchievementsStepsSolvedNumberKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedNumberKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedNumberKindDescription567890", comment: "")
                ]
            case .codeQuizzesSolvedPython:
                return [
                    NSLocalizedString("AchievementsCodeQuizzesSolvedPythonKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsCodeQuizzesSolvedPythonKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsCodeQuizzesSolvedPythonKindDescription567890", comment: "")
                ]
            case .codeQuizzesSolvedJava:
                return [
                    NSLocalizedString("AchievementsCodeQuizzesSolvedJavaKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsCodeQuizzesSolvedJavaKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsCodeQuizzesSolvedJavaKindDescription567890", comment: "")
                ]
            case .codeQuizzesSolvedCPP:
                return [
                    NSLocalizedString("AchievementsCodeQuizzesSolvedCppKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsCodeQuizzesSolvedCppKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsCodeQuizzesSolvedCppKindDescription567890", comment: "")
                ]
            case .certificatesRegularCount:
                return [
                    NSLocalizedString("AchievementsCertificatesRegularCountKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsCertificatesRegularCountKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsCertificatesRegularCountKindDescription567890", comment: "")
                ]
            case .certificatesDistinctionCount:
                return [
                    NSLocalizedString("AchievementsCertificatesDistinctionCountKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsCertificatesDistinctionCountKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsCertificatesDistinctionCountKindDescription567890", comment: "")
                ]
            case .courseReviewsCount:
                return [
                    NSLocalizedString("AchievementsCourseReviewsCountKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsCourseReviewsCountKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsCourseReviewsCountKindDescription567890", comment: "")
                ]
            case .stepsSolvedStreak:
                return [
                    NSLocalizedString("AchievementsStepsSolvedStreakKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedStreakKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsStepsSolvedStreakKindDescription567890", comment: "")
                ]
            case .activeDaysStreak:
                return [
                    NSLocalizedString("AchievementsActiveDaysStreakKindDescription1", comment: ""),
                    NSLocalizedString("AchievementsActiveDaysStreakKindDescription234", comment: ""),
                    NSLocalizedString("AchievementsActiveDaysStreakKindDescription567890", comment: "")
                ]
            }
        }()

        let pluralizedString = StringHelper.pluralize(number: score, forms: forms)

        return String(format: pluralizedString, "\(score)")
    }
}
