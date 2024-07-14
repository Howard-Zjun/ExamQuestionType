//
//  QueContentTitleModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit

class QueContentTitleModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentTitleCell.self
    }
    
    var contentInset: UIEdgeInsets = .init(top: 5, left: 18, bottom: 5, right: 18)
    
    var estimatedHeight: CGFloat?

    let title: String
    
    let qstTitle: String?
    
    init(title: String, qsTitle: String?) {
        self.title = title
        self.qstTitle = qsTitle
    }
    
    init(queLevel1: QueLevel1) {
        self.title = queLevel1.name
        self.qstTitle = queLevel1.descri
    }
}
