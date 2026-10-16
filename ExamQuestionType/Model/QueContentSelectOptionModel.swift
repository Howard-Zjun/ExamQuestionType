//
//  QueContentSelectOptionModel.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/07/09.
//

import UIKit

class QueContentSelectOptionModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentSelectOptionCell.self
    }
    
    var contentInset: UIEdgeInsets = .init(top: 10, left: 18, bottom: 0, right: 18)
    
    var estimatedHeight: CGFloat?

    let options: [String]
    
    let question: QuestionNode
    
    var selectIndex: Int?
    
    let isResult: Bool
    
    init?(question: QuestionNode, isResult: Bool) {
        guard let options = question.options, !options.isEmpty else {
            return nil
        }
        
        self.options = options
        self.question = question
        self.isResult = isResult
    }
}
