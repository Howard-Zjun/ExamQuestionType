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
    
    let queLevel2: QueLevel2
    
    var selectIndex: Int?
    
    let isResult: Bool
    
    init?(queLevel2: QueLevel2, isResult: Bool) {
        guard let options = queLevel2.options, !options.isEmpty else {
            return nil
        }
        
        self.options = options
        self.queLevel2 = queLevel2
        self.isResult = isResult
    }
}
