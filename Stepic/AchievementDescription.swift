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
        return UIImage(named: "achievement-\(self.hashValue + 1)-\(level)") ?? #imageLiteral(resourceName: "achievement-0")
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
        default:
            return NSLocalizedString("AchievementsUnknownKindTitle", comment: "")
        }
    }

    func getDescription(for score: Int) -> String {
        switch self {
        case .stepsSolved:
            return String(format: NSLocalizedString("AchievementsStepsSolvedKindDescription", comment: ""), "\(score)")
        case .stepsSolvedChoice:
            return String(format: NSLocalizedString("AchievementsStepsSolvedChoiceKindDescription", comment: ""), "\(score)")
        case .stepsSolvedCode:
            return String(format: NSLocalizedString("AchievementsStepsSolvedCodeKindDescription", comment: ""), "\(score)")
        case .stepsSolvedNumber:
            return String(format: NSLocalizedString("AchievementsStepsSolvedNumberKindDescription", comment: ""), "\(score)")
        case .codeQuizzesSolvedPython:
            return String(format: NSLocalizedString("AchievementsCodeQuizzesSolvedPythonKindDescription", comment: ""), "\(score)")
        case .codeQuizzesSolvedJava:
            return String(format: NSLocalizedString("AchievementsCodeQuizzesSolvedJavaKindDescription", comment: ""), "\(score)")
        case .codeQuizzesSolvedCPP:
            return String(format: NSLocalizedString("AchievementsCodeQuizzesSolvedCppKindDescription", comment: ""), "\(score)")
        case .certificatesRegularCount:
            return String(format: NSLocalizedString("AchievementsCertificatesRegularCountKindDescription", comment: ""), "\(score)")
        case .certificatesDistinctionCount:
            return String(format: NSLocalizedString("AchievementsCertificatesDistinctionCountKindDescription", comment: ""), "\(score)")
        case .courseReviewsCount:
            return String(format: NSLocalizedString("AchievementsCourseReviewsCountKindDescription", comment: ""), "\(score)")
        case .stepsSolvedStreak:
            return String(format: NSLocalizedString("AchievementsStepsSolvedStreakKindDescription", comment: ""), "\(score)")
        case .activeDaysStreak:
            return String(format: NSLocalizedString("AchievementsActiveDaysStreakKindDescription", comment: ""), "\(score)")
        default:
            return NSLocalizedString("AchievementsUnknownKindDescription", comment: "")
        }
    }
}
