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
     
    var widthUnit: CGFloat
    
    var heightUnit: CGFloat
    
    init(font: UIFont = .systemFont(ofSize: 18),
         textColor: UIColor = .black,
         backgroundColor: UIColor = .white,
         textAlignment: NSTextAlignment = .center,
         boardColor: UIColor = .black,
         boardWidth: CGFloat = 1,
         widthUnit: CGFloat = 50,
         heightUnit: CGFloat = 50) {
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.textAlignment = textAlignment
        self.boardColor = boardColor
        self.boardWidth = boardWidth
        self.widthUnit = widthUnit
        self.heightUnit = heightUnit
    }
    
    static let contentModel: EQTableConfig = .init()
    
    static let headConfig: EQTableConfig = .init(font: .systemFont(ofSize: 18, weight: .bold))
}

class EQTableTdModel: NSObject {
    
    var xNum: Int = 0
    
    var yNum: Int = 0
    
    var x: CGFloat {
        CGFloat(xNum) * configModel.widthUnit
    }
    
    var y: CGFloat {
        CGFloat(yNum) * configModel.heightUnit
    }
    
    var origin: CGPoint {
        .init(x: x, y: y)
    }
    
    var widthNum: Int = 1
    
    var heightNum: Int = 1
    
    var width: CGFloat {
        CGFloat(widthNum) * configModel.widthUnit
    }
    
    var height: CGFloat {
        CGFloat(heightNum) * configModel.heightUnit
    }
    
    var size: CGSize {
        .init(width: width, height: height)
    }
    
    var marginInset: UIEdgeInsets = .zero
    
    var paddingInset: UIEdgeInsets = .zero
    
    var content: String
    
    var configModel: EQTableConfig = .contentModel
    
    init?(element: TFHppleElement) {
        if element.tagName == "td" {
            return nil
        }
        self.content = element.content
        // 跨行
        if let rowspan = element.attributes["rowspan"] as? Int {
            heightNum = rowspan
        }
        // 跨列
        if let colspan = element.attributes["colspan"] as? Int {
            widthNum = colspan
        }
    }
}
