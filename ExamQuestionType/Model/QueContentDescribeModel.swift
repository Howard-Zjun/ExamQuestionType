//
//  QueContentDescribeModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit

class QueContentDescribeModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentDescribeCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let queLevel2: QueLevel2
    
    var handleContent: String?
    
    var handleContentAttr: NSAttributedString?
    
    init?(queLevel2: QueLevel2) {
        guard let content = queLevel2.content else {
            return nil
        }
        
        self.queLevel2 = queLevel2
        handleContent = "\(queLevel2.no)" + HTMLTranslate.stripBlk(html: queLevel2.content ?? "")
    }
}
