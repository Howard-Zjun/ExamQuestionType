//
//  QueContentVoiceModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit
import AVFoundation

class QueContentVoiceModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentVoiceCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    var estimatedHeight: CGFloat?

    let question: QuestionNode
    
    let voiceUrl: String
    
    init?(question: QuestionNode) {
        guard let voiceUrl = question.voiceUrl, let url = URL(string: voiceUrl) else {
            return nil
        }
        
        self.question = question
        self.voiceUrl = voiceUrl
        let asset = AVAsset(url: url)
    }
}
