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
    
    var contentInset: UIEdgeInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
    
    var estimatedHeight: CGFloat?

    let options: [String]
    
    let queLevel2: QueLevel2
    
    var selectIndex: Int?
    
    init?(queLevel2: QueLevel2) {
        guard let options = queLevel2.options, !options.isEmpty else {
            return nil
        }
        
        self.options = options
        self.queLevel2 = queLevel2
    }
}
