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
    
    let queLevel2: QueLevel2
    
    let voiceUrl: String
    
    init?(queLevel2: QueLevel2) {
        guard let voiceUrl = queLevel2.voiceUrl, let url = URL(string: voiceUrl) else {
            return nil
        }
        
        self.queLevel2 = queLevel2
        self.voiceUrl = voiceUrl
        let asset = AVAsset(url: url)
    }
}
