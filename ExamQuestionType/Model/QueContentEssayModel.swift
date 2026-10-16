//
//  QueContentEssayModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/13.
//

import UIKit

class QueContentEssayModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentEssayCell.self
    }
    
    var contentInset: UIEdgeInsets = .init(top: 10, left: 18, bottom: 0, right: 18)
    
    var estimatedHeight: CGFloat?
    
    let question: QuestionNode
    
    let index: Int
    
    var isFocuns: Bool = false
    
    let isResult: Bool
    
    init?(question: QuestionNode, index: Int, isResult: Bool) {
        guard question.type == .Essay else {
            return nil
        }
        self.question = question
        self.index = index
        self.isResult = isResult
    }
    
    // 设置答案
    func setAnswer(text: String) {
        while question.userAnswers.count <= index {
            question.userAnswers.append("")
        }
        question.userAnswers[index] = text
    }
    
    func getAnswer() -> String {
        while question.userAnswers.count <= index {
            question.userAnswers.append("")
        }
        return question.userAnswers[index]
    }
}
