//
//  QueLevel1.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/21.
//

import UIKit

class QueLevel1: NSObject, Decodable {

    let name: String
    
    let descri: String?
    
    let type: QueLevel1Type
    
    let queLevel2Arr: [QueLevel2]
    
    enum CodingKeys: String, CodingKey {
        case name
        case descri
        case type
        case queLevel2Arr
    }
    
    init(name: String, descri: String?, type: QueLevel1Type, queLevel2Arr: [QueLevel2]) {
        self.name = name
        self.descri = descri
        self.type = type
        self.queLevel2Arr = queLevel2Arr
    }
}

extension QueLevel1 {
    
    enum QueLevel1Type: Int {
        case cloze = 0
        case readComprehension
        case wordPractice
        case listen
    }
}

extension QueLevel1 {
    
    static var closeModel: QueLevel1 {
        .init(name: "完形填空", descri: "请完成以下练习", type: .cloze, queLevel2Arr: [
            
        ])
    }
    
    static var readComprehensionModel: QueLevel1 {
        .init(name: "阅读裂解", descri: "请完成以下练习", type: .readComprehension, queLevel2Arr: [
        
        ])
    }
    
    static var wordPracticeModel: QueLevel1 {
        .init(name: "单词练习", descri: <#T##String#>, type: <#T##QueLevel1Type#>, queLevel2Arr: <#T##[QueLevel2]#>)
    }
    
    static var listenModel: QueLevel1 {
        .init(name: "听力", descri: <#T##String#>, type: .listen, queLevel2Arr: [
            
        ])
    }
}
