//
//  EQTableTrModel.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/10.
//

import UIKit

class EQTableTrModel: NSObject {

    
    let tdModelArr: [EQTableTdModel]
    
    init?(element: TFHppleElement) {
        if element.tagName == "tr" {
            return nil
        }
        var tdModelArr: [EQTableTdModel] = []
        for itemElement in (element.children as? [TFHppleElement]) ?? [] {
            if itemElement.tagName == "td" {
                if let model = EQTableTdModel(element: itemElement, x: 0, y: 0) {
                    tdModelArr.append(model)
                }
            }
        }
        if tdModelArr.isEmpty {
            return nil
        }
        self.tdModelArr = tdModelArr
    }
}
