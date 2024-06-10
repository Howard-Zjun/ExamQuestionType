//
//  EQTableModel.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/10.
//

import UIKit

class EQTableModel: NSObject {

    let theadModel: EQTableHeadModel?
    
    let trModelArr: [EQTableTrModel]
    
    let expansionTrModelArr: [EQTableTdModel]
    
    init?(htmlStr: String) {
        if let data = htmlStr.data(using: .utf8) {
            var theadModel: EQTableHeadModel?
            var trModelArr: [EQTableTrModel] = []

            let hpple = TFHpple(data: data, isXML: false)
            let arr = hpple?.search(withXPathQuery: "//table") as? [TFHppleElement]
            for item in arr ?? [] {
                if item.tagName == "thead" {
                    if let model = EQTableHeadModel(element: item) {
                        theadModel = model
                    }
                } else if item.tagName == "tr" {
                    if let model = EQTableTrModel(element: item) {
                        trModelArr.append(model)
                    }
                }
            }
            if trModelArr.isEmpty {
                return nil
            }
            self.theadModel = theadModel
            self.trModelArr = trModelArr
            self.expansionTrModelArr = trModelArr.flatMap({$0.tdModelArr})
        } else {
            return nil
        }
        
        var col = 0 // 列坐标
        var row = 0 // 行坐标
        if let theadModel = theadModel {
            for (trIndex, trModel) in theadModel.trModelArr.enumerated() {
                for (tdIndex, tdModel) in trModel.tdModelArr.enumerated() {
                    tdModel.yNum = trIndex
                    tdModel.xNum = tdIndex
                    tdModel.configModel = .headConfig
                }
                row += 1
            }
        }
        var tempArr: [Int] = .init(repeating: 0, count: trModelArr[0].tdModelArr.count)
        
        for (trIndex, trModel) in trModelArr.enumerated() {
            var left = 0 // 当前正在修改的下标
            var right = 0
            var colOffset = 0
            while left < trModel.tdModelArr.count {
                if tempArr[right] == 0 && colOffset == 0 {
                    trModel.tdModelArr[left].yNum = trIndex + (theadModel?.trModelArr.count ?? 0)
                    trModel.tdModelArr[left].xNum = col
                    
                    
                    left += 1
                }
            }
            row += 1
        }
    }
}
