//
//  QueContentRecordModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit

class QueContentRecordModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        ConversationCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let queLevel2: QueLevel2
    
    init?(queLevel2: QueLevel2) {
        guard queLevel2.type == .Record else { return }
        self.queLevel2 = queLevel2
    }
}
