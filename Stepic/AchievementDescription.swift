//
//  AchievementDescription.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum AchievementKind: String {
    // Cases should be declared in correct order
    case stepsSolved = "steps_solved"
    case stepsSolvedStreak = "steps_solved_streak"
    case stepsSolvedChoice = "steps_solved_choice"
    case stepsSolvedCode = "steps_solved_code"
    case stepsSolvedNumber = "steps_solved_number"
    case codeQuizzesSolvedPython = "code_quizzes_solved_python"
    case codeQuizzesSolvedJava = "code_quizzes_solved_java"
    case codeQuizzesSolvedCPP = "code_quizzes_solved_cpp"
    case activeDaysStreak = "active_days_streak"
    case certificatesRegularCount = "certificates_regular_count"
    case certificatesDistinctionCount = "certificates_distinction_count"
    case courseReviewsCount = "course_reviews_count"

    func getBadge(for level: Int) -> UIImage? {
        return UIImage(named: "achievement-\(self.hashValue + 1)-\(level)")
    }

    func getName() -> String {
        switch self {
        case .stepsSolved:
            return "Главное – количество"
        case .stepsSolvedChoice:
            return "Я выбираю"
        case .stepsSolvedCode:
            return "Компьютерный мастер"
        case .stepsSolvedNumber:
            return "Ещё одно достижение"
        case .codeQuizzesSolvedPython:
            return "Укротитель змей"
        case .codeQuizzesSolvedJava:
            return "Немного кофе?"
        case .codeQuizzesSolvedCPP:
            return "Developer.cpp"
        case .certificatesRegularCount:
            return "Выпускник"
        case .certificatesDistinctionCount:
            return "Отличник"
        case .courseReviewsCount:
            return "Критик"
        case .stepsSolvedStreak:
            return "Сапёр"
        case .activeDaysStreak:
            return "Постоянный пользователь"
        }
    }
}
