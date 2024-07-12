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
    
    var estimatedHeight: CGFloat?

    let videoUrl: String
    
    init?(queLevel2: QueLevel2) {
        guard let videoUrl = queLevel2.videoUrl else {
            return nil
        }
        self.videoUrl = videoUrl
    }
}
