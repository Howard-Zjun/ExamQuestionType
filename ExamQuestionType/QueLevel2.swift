//
//  QueLevel2.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/21.
//

import UIKit

class QueLevel2: NSObject, Decodable {

    let videoUrl: String?
    
    let voiceUrl: String?
    
    let subLevel2: [QueLevel2]?
    
    var content: String?
    
    let correctAnswers: [String]?
    
    var userAnswers: [String]
    
    let options: [String]?
    
    let type: QueLevel2Type
    
    let no: Int?
    
    let score: Int
    
    var userScore: Int
    
    enum CodingKeys: String, CodingKey {
        case videoUrl
        case voiceUrl
        case subLevel2
        case content
        case correctAnswers
        case userAnswers
        case options
        case type
        case no
        case score
        case userScore
    }
        
    
    init(videoUrl: String?, voiceUrl: String?, subLevel2: [QueLevel2]?, content: String?, correctAnswers: [String]?, options: [String]?, type: QueLevel2Type, no: Int?) {
        self.videoUrl = videoUrl
        self.voiceUrl = voiceUrl
        self.subLevel2 = subLevel2
        self.content = content
        self.correctAnswers = correctAnswers
        self.userAnswers = []
        self.options = options
        self.type = type
        self.no = no
    }
    
    override func copy() -> Any {
        var subLevel2: [QueLevel2] = []
        for item in self.subLevel2 {
            subLevel2.append(item.copy())
        }
        return QueLevel2(videoUrl: videoUrl, voiceUrl: voiceUrl, subLevel2: subLevel2, content: content, correctAnswers: correctAnswers, userAnswers: userAnswers, options: options, type: type, no: no)
    }
}

extension QueLevel2 {
    
    enum QueLevel2Type: Int {
        case FillBlank = 0
        case Select
        case Record
        case Sort
        case Comprehensive
    }
}

extension QueLevel2 {
    
    static var closeModel: QueLevel2 {
        
    }
    
    static var readComprehensionSubModel: QueLevel2 {
        
    }
    
    static var essayFillBlankSubModel: QueLevel2 {
        
    }
}
