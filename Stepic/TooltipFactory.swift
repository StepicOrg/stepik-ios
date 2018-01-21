//
//  TooltipFactory.swift
//  Stepic
//
//  Created by Ostrenkiy on 19.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct TooltipFactory {
    static var sharingCourse: Tooltip {
        return EasyTipTooltip(text: "Поделитесь ссылкой с друзьями, чтобы проходить курс вместе!", shouldDismissAfterTime: true)
    }

    static var lessonDownload: Tooltip {
        return EasyTipTooltip(text: "Загрузите урок, чтобы смотреть видео оффлайн", shouldDismissAfterTime: true)
    }

    static var continueLearningWidget: Tooltip {
        return EasyTipTooltip(text: "Нажмите, чтобы перейти к тому месту, где закончили в прошлый раз", shouldDismissAfterTime: true)
    }

    static var streaksTooltip: Tooltip {
        return EasyTipTooltip(text: "Включите, чтобы получать новую порцию знаний каждый день", shouldDismissAfterTime: true)
    }
}
