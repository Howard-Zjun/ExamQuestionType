//
//  QuestionNode.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/21.
//

import UIKit

class QuestionNode: NSObject {

    let videoUrl: String?
    
    let voiceUrl: String?
    
    let subquestions: [QuestionNode]?
    
    var content: String?
    
    let correctAnswers: [String]?
    
    let options: [String]?
    
    let type: QuestionNodeType
    
    let no: String?
    
    var isNormal: Bool
    
    var userAnswers: [String] = []
    
    init(videoUrl: String?, voiceUrl: String?, subquestions: [QuestionNode]?, content: String?, correctAnswers: [String]?, options: [String]?, type: QuestionNodeType, no: String?, isNormal: Bool) {
        self.videoUrl = videoUrl
        self.voiceUrl = voiceUrl
        self.subquestions = subquestions
        self.content = content
        self.correctAnswers = correctAnswers
        self.options = options
        self.type = type
        self.no = no
        self.isNormal = isNormal
    }
    
    func resolver(isResult: Bool) -> [QueContentModel] {
        if type == .SelectFillBlank {
            return QueContentResolver.selectFillBlankResolver(question: self, isResult: isResult)
        } else {
            var queue: [QuestionNode] = [self]
            var models: [QueContentModel] = []
            var index = 0
            while index < queue.count {
                let temp = queue[index]
                
                if temp.type == .FillBlank {
                    models += QueContentResolver.fillBlankResolver(question: temp, isResult: isResult)
                } else if temp.type == .Essay {
                    models += QueContentResolver.essayResolver(question: temp, isResult: isResult)
                } else if temp.type == .Select {
                    models += QueContentResolver.selectResolver(question: temp, isResult: isResult)
                } else {
                    models += QueContentResolver.normalResolver(question: temp, isResult: isResult)
                }
                
                if !temp.isNormal, let subquestions = temp.subquestions {
                    queue += subquestions
                }
                
                index += 1
            }
            
            return models
        }
    }
}

extension QuestionNode {
    
    /// 题目类型
    enum QuestionNodeType: Int {
        case FillBlank = 0
        case SelectFillBlank
        case Select
        case Record
        case Essay
    }
}
