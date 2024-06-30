//
//  QueContentTableModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit

class QueContentTableModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentTableCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let tableModel: EQTableModel
    
    init?(html: String) {
        guard let tableModel = EQTableModel(html: html) else {
            return nil
        }
        self.tableModel = tableModel
    }
    
    convenience init?(queLevel2: QueLevel2) {
        guard let content = queLevel2.content else {
            return nil
        }
        self.init(html: content)
    }
}

class EQTableModel: NSObject {
    
    let theadModel: EQTableHeadModel?
    
    let trModelArr: [EQTableTrModel]
    
    var suffixContent: String?
    
    let expansionTrModelArr: [EQTableTdModel]
    
    let maxColCount: Int
    
    let rowCount: Int
    
    init?(html: String) {
        if let data = html.data(using: .utf8) {
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
        
        let range = (html as NSString).range(of: "</table>")
        let suffixStr = (html as NSString).substring(from: range.location + range.length)
        if let data = suffixStr.data(using: .utf8) {
            let hpple = TFHpple(data: data, isXML: false)
            let arr = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement]
            for item in arr ?? [] {
                if item.tagName == "p" {
                    if suffixContent == nil {
                        suffixContent = ""
                    }
                    suffixContent! += item.content
                }
            }
        }
        
        var maxColCount = 0
        var rowCount = 0
        if let theadModel = theadModel {
            for (trIndex, trModel) in theadModel.trModelArr.enumerated() {
                maxColCount = max(maxColCount, trModel.tdModelArr.count)
                rowCount += 1
                for (tdIndex, tdModel) in trModel.tdModelArr.enumerated() {
                    tdModel.yNum = trIndex
                    tdModel.xNum = tdIndex
                    tdModel.configModel = .headConfig
                }
            }
        }
        for trModel in trModelArr {
            maxColCount = max(maxColCount, trModel.tdModelArr.count)
            rowCount += 1
        }
        
        self.maxColCount = maxColCount
        self.rowCount = rowCount
        
        // 将单元所在位置修正，下面是数据都正确的处理逻辑，没有应对异常的处理
        
        // 每一列的阻碍
        var barrierArr: [Int] = .init(repeating: 0, count: maxColCount)
        
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

class EQTableHeadModel: NSObject {

    let trModelArr: [EQTableTrModel]
    
    init?(element: TFHppleElement) {
        if element.tagName != "thead" {
            return nil
        }
        var trModelArr: [EQTableTrModel] = []
        for itemElement in (element.children as? [TFHppleElement]) ?? [] {
            if itemElement.tagName != "tr" {
                continue
            }
            if let model = EQTableTrModel(element: itemElement) {
                trModelArr.append(model)
            }
        }
        if trModelArr.isEmpty {
            return nil
        }
        self.trModelArr = trModelArr
    }
}

class EQTableTrModel: NSObject {

    
    let tdModelArr: [EQTableTdModel]
    
    init?(element: TFHppleElement) {
        if element.tagName != "tr" {
            return nil
        }
        var tdModelArr: [EQTableTdModel] = []
        for itemElement in (element.children as? [TFHppleElement]) ?? [] {
            if itemElement.tagName == "td" {
                if let model = EQTableTdModel(element: itemElement) {
                    tdModelArr.append(model)
                }
            }
        }
        if tdModelArr.isEmpty {
            return nil
        }
        tdModelArr.last?.isLast = true
        self.tdModelArr = tdModelArr
    }
}

class EQTableConfig: NSObject {
    
    var font: UIFont
    
    var textColor: UIColor
    
    var backgroundColor: UIColor

    var textAlignment: NSTextAlignment
    
    var boardColor: UIColor
    
    var boardWidth: CGFloat
    
    init(font: UIFont = .systemFont(ofSize: 14),
         textColor: UIColor = .black,
         backgroundColor: UIColor = .white,
         textAlignment: NSTextAlignment = .left,
         boardColor: UIColor = .black,
         boardWidth: CGFloat = 0.5) {
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
    
    // 是否该行最后一个
    var isLast: Bool = false
    
    var content: String
    
    var configModel: EQTableConfig = .contentModel
    
    init?(element: TFHppleElement) {
        if element.tagName != "td" {
            return nil
        }
        if element.raw.contains("</u>") { // 包含下划线
            var content = ""
            var index = 0
            var queue: [TFHppleElement] = element.children as! [TFHppleElement]
            while index < queue.count {
                let item = queue[index]
                if item.tagName == "u" {
                    content += "___"
                } else if item.tagName == "text" {
                    content += item.content
                } else {
                    queue += item.children as! [TFHppleElement]
                }
                index += 1
            }
            self.content = content
        } else {
            self.content = element.content
        }
        
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


