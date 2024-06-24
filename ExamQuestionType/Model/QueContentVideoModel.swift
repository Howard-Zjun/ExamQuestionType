//
//  QueContentVideoModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/18.
//

import UIKit

class QueContentVideoModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentVideoCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let qstDetailLevel2: QueLevel2
    
    let videoUrl: String
    
    init?(queLevel2: QueLevel2) {
        guard let videoUrl = queLevel2.videoUrl else {
            return nil
        }
        self.queLevel2 = queLevel2
        self.videoUrl = videoUrl
    }
}
