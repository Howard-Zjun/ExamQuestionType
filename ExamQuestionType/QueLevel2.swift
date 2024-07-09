//
//  QueLevel2.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/21.
//

import UIKit

class QueLevel2: NSObject {

    let videoUrl: String?
    
    let voiceUrl: String?
    
    let subLevel2: [QueLevel2]?
    
    var content: String?
    
    let correctAnswers: [String]?
    
    let options: [String]?
    
    let type: QueLevel2Type
    
    let no: String?
    
    var isNormal: Bool
    
    var userAnswers: [String] = []
    
    init(videoUrl: String?, voiceUrl: String?, subLevel2: [QueLevel2]?, content: String?, correctAnswers: [String]?, options: [String]?, type: QueLevel2Type, no: String?, isNormal: Bool) {
        self.videoUrl = videoUrl
        self.voiceUrl = voiceUrl
        self.subLevel2 = subLevel2
        self.content = content
        self.correctAnswers = correctAnswers
        self.options = options
        self.type = type
        self.no = no
        self.isNormal = isNormal
    }
}

extension QueLevel2 {
    
    enum QueLevel2Type: Int {
        case FillBlank = 0
        case SelectFillBlank
        case Select
        case Record
        case Essay
    }
}
