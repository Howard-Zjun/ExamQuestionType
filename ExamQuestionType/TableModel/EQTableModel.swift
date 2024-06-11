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
            let arr = (hpple?.search(withXPathQuery: "//table") as? [TFHppleElement])?.first?.children as? [TFHppleElement]
            for item in arr ?? [] {
                if item.tagName == "thead" {
                    if let model = EQTableHeadModel(element: item) {
                        theadModel = model
                    }
                } else if item.tagName == "tbody" {
                    let itemChildren = item.children as? [TFHppleElement]
                    for child in itemChildren ?? [] {
                        if child.tagName != "tr" {
                            continue
                        }
                        if let model = EQTableTrModel(element: child) {
                            trModelArr.append(model)
                        }
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
        
        if let theadModel = theadModel {
            for (trIndex, trModel) in theadModel.trModelArr.enumerated() {
                for (tdIndex, tdModel) in trModel.tdModelArr.enumerated() {
                    tdModel.yNum = trIndex
                    tdModel.xNum = tdIndex
                    tdModel.configModel = .headConfig
                }
            }
        }
        
        // 将单元所在位置修正，下面是数据都正确的处理逻辑，没有应对异常的处理
        
        // 每一列的阻碍
        var barrierArr: [Int] = .init(repeating: 0, count: trModelArr[0].tdModelArr.count)
        let maxColCount = theadModel?.trModelArr.first?.tdModelArr.count ?? barrierArr.count
        
        for (trIndex, trModel) in trModelArr.enumerated() {
            var left = 0 // 当前等待修正的下标
            var right = 0 // 指向的下标
            while right < maxColCount && left < trModel.tdModelArr.count {
                let model = trModel.tdModelArr[left]
                
                var haveBarrier = false
                // 之后看能不能优化
                for index in 0..<model.widthNum {
                    if right + index >= barrierArr.count {
                        haveBarrier = true
                        break
                    }
                    if barrierArr[right + index] > 0 {
                        haveBarrier = true
                        
                        barrierArr[right + index] -= 1
                    }
                }
                
                if haveBarrier { // 有障碍, 变更操作的下标，等下一次轮训处理
                    right += model.widthNum
                } else { // 没有障碍可以修正位置
                    trModel.tdModelArr[left].yNum = trIndex + (theadModel?.trModelArr.count ?? 0)
                    trModel.tdModelArr[left].xNum = right
                    
                    // 将单元跨行填入障碍
                    for index in 0..<model.widthNum {
                        if right + index >= barrierArr.count {
                            break
                        }
                        barrierArr[right + index] = model.heightNum - 1
                    }
                    left += 1
                    
                    right += 1
                }
            }
        }
    }
}
