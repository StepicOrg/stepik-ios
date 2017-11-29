//
//  CourseTag.swift
//  Stepic
//
//  Created by Ostrenkiy on 21.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CourseTag {
    var ID: Int
    var titleForLanguage: [ContentLanguage: String] = [:]
    var summaryForLanguage: [ContentLanguage: String] = [:]

    init(ID: Int, ruTitle: String, enTitle: String, ruSummary: String, enSummary: String) {
        self.ID = ID
        self.titleForLanguage[ContentLanguage.english] = enTitle
        self.titleForLanguage[ContentLanguage.russian] = ruTitle
    }

    static let featuredTags: [CourseTag] = [
        CourseTag(ID: 22760,
                  ruTitle: "математика",
                  enTitle: "mathematics",
                  ruSummary: "наука о структурах, порядке и отношениях",
                  enSummary: "abstract study of numbers, quantity, structure, relationships, etc."
        ),
        CourseTag(ID: 866,
                  ruTitle: "статистика",
                  enTitle: "statistics",
                  ruSummary: "отрасль знаний о сборе, измерении, анализе, толковании и представлении данных",
                  enSummary: "study of the collection, organization, analysis, interpretation, and presentation of data"
        ),
        CourseTag(ID: 22872,
                  ruTitle: "информатика",
                  enTitle: "computer science",
                  ruSummary: "дисциплина о применении компьютерной техники",
                  enSummary: "study of the theoretical foundations of information and computation"
        ),
        CourseTag(ID: 485282,
                  ruTitle: "естественные науки",
                  enTitle: "natural science",
                  ruSummary: "разделы науки, отвечающие за изучение природных явлений",
                  enSummary: "branch of science about the natural world"
        ),
        CourseTag(ID: 20521,
                  ruTitle: "общественные науки",
                  enTitle: "social science",
                  ruSummary: "науки об обществе и взаимоотношениях",
                  enSummary: "academic discipline concerned with society and the relationships"
        ),
        CourseTag(ID: 33808,
                  ruTitle: "гуманитарные науки",
                  enTitle: "humanities",
                  ruSummary: "дисциплины, изучающие человека в сфере его духовной, умственной, нравственной, культурной и общественной деятельности",
                  enSummary: "academic disciplines that study human culture"
        )
    ]
}
