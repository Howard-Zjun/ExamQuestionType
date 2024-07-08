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
    
    var contentInset: UIEdgeInsets = .init(top: 10, left: 0, bottom: 10, right: 0)
    
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
    
    let expansionTrModelArr: [EQTableTdModel]
    
    var maxColCount: Int

    var rowCount: Int
    
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
            self.maxColCount = 1
            self.rowCount = 1
        } else {
            return nil
        }
        
        super.init()

        var maxColCount = 0 // 最大列数
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
        
        for (trIndex, trModel) in ((theadModel?.trModelArr ?? []) + trModelArr).enumerated() {
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
            print(trModel.tdModelArr.map({"xNum: \($0.xNum) yNum: \($0.yNum) widthNum: \($0.widthNum) heightNum: \($0.heightNum)"}))
            print("------")
        }
        
        adjustSize()
    }
    
    /// 单元大小适应
    func adjustSize(contentWidth: CGFloat = kScreenWidth - 40) {
        var arr: [[EQTableTdModel]] = .init(repeating: [], count: rowCount)
        
        for trModel in (theadModel?.trModelArr ?? []) + trModelArr {
            for tdModel in trModel.tdModelArr {
                arr[tdModel.yNum + tdModel.heightNum - 1].append(tdModel)
            }
        }
        
        var maxY: CGFloat = 0
        let colSpan = floor(contentWidth / CGFloat(maxColCount))
        for (trIndex, trModel) in ((theadModel?.trModelArr ?? []) + trModelArr).enumerated() {
            var maxContentHeight: CGFloat = 0
            for tdModel in trModel.tdModelArr {
                tdModel.x = CGFloat(tdModel.xNum) * colSpan
                tdModel.y = maxY
                if tdModel.isLast {
                    tdModel.width = contentWidth - tdModel.x
                } else {
                    tdModel.width = CGFloat(tdModel.widthNum) * colSpan
                }
                maxContentHeight = max(maxContentHeight, tdModel.attr.string.textHeight(textWidth: tdModel.width, font: tdModel.configModel.font))
            }
            
            maxY += maxContentHeight + 20
            for tdModel in arr[trIndex] {
                tdModel.height = maxY - tdModel.y
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
    
    var boardColor: UIColor
    
    var boardWidth: CGFloat
    
    init(font: UIFont = .systemFont(ofSize: 14),
         textColor: UIColor = .black,
         backgroundColor: UIColor = .white,
         boardColor: UIColor = .black,
         boardWidth: CGFloat = 0.5) {
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.boardColor = boardColor
        self.boardWidth = boardWidth
    }
    
    static let contentModel: EQTableConfig = .init()
    
    static let headConfig: EQTableConfig = .init(font: .systemFont(ofSize: 18, weight: .bold))
}

class EQTableTdModel: NSObject {
    
    var xNum: Int = 0
    
    var yNum: Int = 0
    
    // 跨列
    var widthNum: Int
    // 跨行
    var heightNum: Int
    
    var x: CGFloat = 0
    
    var y: CGFloat = 0
    
    var width: CGFloat = 0
    
    var height: CGFloat = 0
    // 是否该行最后一个
    var isLast: Bool = false
    
    let attr: NSMutableAttributedString
    
    var configModel: EQTableConfig = .contentModel
    
    init?(element: TFHppleElement) {
        if element.tagName != "td" {
            return nil
        }
        let firstEnd = (element.raw as NSString).range(of: ">").location + 1
        let html = (element.raw as NSString).substring(with: .init(location: firstEnd, length: element.raw.count - firstEnd - 4))
        if let describeModel = QueContentDescribeModel(html: html, needStyle: false) {
            attr = describeModel.handleContentAttr
        } else {
            attr = NSMutableAttributedString(string: element.content)
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


