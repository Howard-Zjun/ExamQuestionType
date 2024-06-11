//
//  EQTableTdModel.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/10.
//

import UIKit

class EQTableConfig: NSObject {
    
    var font: UIFont
    
    var textColor: UIColor
    
    var backgroundColor: UIColor

    var textAlignment: NSTextAlignment
    
    var boardColor: UIColor
    
    var boardWidth: CGFloat
    
    init(font: UIFont = .systemFont(ofSize: 18),
         textColor: UIColor = .black,
         backgroundColor: UIColor = .white,
         textAlignment: NSTextAlignment = .left,
         boardColor: UIColor = .black,
         boardWidth: CGFloat = 1) {
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.textAlignment = textAlignment
        self.boardColor = boardColor
        self.boardWidth = boardWidth
    }
    
    static let contentModel: EQTableConfig = .init()
    
    static let headConfig: EQTableConfig = .init(font: .systemFont(ofSize: 18, weight: .bold))
}

class EQTableTdModel: NSObject {
    
    var xNum: Int = 0
    
    var yNum: Int = 0
    
    var widthNum: Int
    
    var heightNum: Int
    
    var marginInset: UIEdgeInsets = .zero
    
    var paddingInset: UIEdgeInsets = .zero
    
    var content: String
    
    var configModel: EQTableConfig = .contentModel
    
    init?(element: TFHppleElement) {
        if element.tagName != "td" {
            return nil
        }
        self.content = element.content
        
        // 跨行
        var heightNum = element.attributes["rowspan"] as? Int
        if heightNum == nil, let str = element.attributes["rowspan"] as? String {
            heightNum = Int(str)
        }
        if let heightNum = heightNum {
            self.heightNum = heightNum
        } else {
            self.heightNum = 1
        }
        
        // 跨列
        var widthNum = element.attributes["colspan"] as? Int
        if widthNum == nil, let str = element.attributes["colspan"] as? String {
            widthNum = Int(str)
        }
        if let widthNum = widthNum {
            self.widthNum = widthNum
        } else {
            self.widthNum = 1
        }
    }
}
