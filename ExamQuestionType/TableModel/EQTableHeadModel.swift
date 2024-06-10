//
//  EQTableHeadModel.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/10.
//

import UIKit

class EQTableHeadModel: NSObject {

    let trModelArr: [EQTableTrModel]
    
    init?(element: TFHppleElement) {
        if element.tagName != "thead" {
            return nil
        }
        var trModelArr: [EQTableTrModel] = []
        for itemElement in (element.children as? [TFHppleElement]) ?? [] {
            if itemElement.tagName == "tr" {
                if let model = EQTableTrModel(element: itemElement) {
                    trModelArr.append(model)
                }
            }
        }
        if trModelArr.isEmpty {
            return nil
        }
        self.trModelArr = trModelArr
    }
}
