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
    
    let queLevel2: QueLevel2
    
    let index: Int
    
    let isResult: Bool
    
    init?(queLevel2: QueLevel2, index: Int, isResult: Bool) {
        guard queLevel2.type == .Essay else {
            return nil
        }
        self.queLevel2 = queLevel2
        self.index = index
        self.isResult = isResult
    }
    
    // 设置答案
    func setAnswer(text: String) {
        while queLevel2.userAnswers.count <= index {
            queLevel2.userAnswers.append("")
        }
        queLevel2.userAnswers[index] = text
    }
    
    func getAnswer() -> String {
        while queLevel2.userAnswers.count <= index {
            queLevel2.userAnswers.append("")
        }
        return queLevel2.userAnswers[index]
    }
}
