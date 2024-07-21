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
    
    var contentInset: UIEdgeInsets = .init(top: 0, left: 18, bottom: 0, right: 18)
    
    var estimatedHeight: CGFloat?

    let tableModel: EQTableModel
    
    weak var delegate: QueContentModelDelegate? {
        didSet {
            for trModel in tableModel.expansionTrModelArr {
                trModel.updateBlock = { [weak self] in
                    guard let self = self else { return }
                    delegate?.contentDidChange(model: self)
                }
            }
        }
    }
    
    init?(queLevel2: QueLevel2, html: String, isResult: Bool = false) {
        guard let tableModel = EQTableModel(html: html, queLevel2: queLevel2, isResult: isResult) else {
            return nil
        }
        tableModel.adjustSize(contentWidth: kScreenWidth - contentInset.left - contentInset.right)
        self.tableModel = tableModel
        if let last = tableModel.expansionTrModelArr.last {
            self.estimatedHeight = last.y + last.height
        } else {
            self.estimatedHeight = CGFloat(tableModel.rowCount) * 55
        }
    }
    
    convenience init?(queLevel2: QueLevel2, isResult: Bool = false) {
        guard let content = queLevel2.content else {
            return nil
        }
        self.init(queLevel2: queLevel2, html: content, isResult: isResult)
    }
}

class EQTableModel: NSObject {
    
    let theadModel: EQTableHeadModel?
    
    let trModelArr: [EQTableTrModel]
    
    let expansionTrModelArr: [EQTableTdModel]
    
    var maxColCount: Int

    var rowCount: Int
    
    init?(html: String, queLevel2: QueLevel2, isResult: Bool) {
        if let data = html.data(using: .utf8) {
            var theadModel: EQTableHeadModel?
            var trModelArr: [EQTableTrModel] = []

            var fillBlankIndex = 0
            let hpple = TFHpple(data: data, isXML: false)
            let arr = (hpple?.search(withXPathQuery: "//table") as? [TFHppleElement])?.first?.children as? [TFHppleElement]
            for item in arr ?? [] {
                if item.tagName == "thead" {
                    if let model = EQTableHeadModel(element: item, queLevel2: queLevel2, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
                        theadModel = model
                    }
                } else if item.tagName == "tbody" {
                    let itemChildren = item.children as? [TFHppleElement]
                    for child in itemChildren ?? [] {
                        if child.tagName != "tr" {
                            continue
                        }
                        if let model = EQTableTrModel(element: child, queLevel2: queLevel2, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
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

        calMaxRowCount()
        
        calMaxColCount()
        
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
    }
    
    func calMaxRowCount() {
        // 计算最大行数
        var rowCount = 0
        if let theadModel = theadModel {
            for (trIndex, trModel) in theadModel.trModelArr.enumerated() {
                rowCount += 1
                for (tdIndex, tdModel) in trModel.tdModelArr.enumerated() {
                    tdModel.configModel = .headConfig
                }
            }
        }
        for trModel in trModelArr {
            rowCount += 1
        }
        print("\(NSStringFromClass(Self.self)) \(#function) 最大行数: \(rowCount)")
        self.rowCount = rowCount
    }
    
    func calMaxColCount() {
        // 最大列数
        var maxColCount = 0
        // 计算每一行的最多列
        var maxColArr: [Int] = .init(repeating: 0, count: rowCount)
        for (trIndex, trModel) in ((theadModel?.trModelArr ?? []) + trModelArr).enumerated() {
            
            // 处理每行里的跨列，填充跨行后，行的宽度
            for (tdIndex, tdModel) in trModel.tdModelArr.enumerated() {
                for i in 0..<tdModel.heightNum {
                    maxColArr[trIndex + i] += tdModel.widthNum
                }
            }
            
            maxColCount = max(maxColCount, maxColArr[trIndex])
        }
        
        print("\(NSStringFromClass(Self.self)) \(#function) 最大列数: \(maxColCount)")
        self.maxColCount = maxColCount
    }
    
    /// 单元大小适应
    func adjustSize(contentWidth: CGFloat) {
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
                maxContentHeight = max(maxContentHeight, tdModel.resultAttributed.textHeight(textWidth: tdModel.width) + 20)
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
    
    init?(element: TFHppleElement, queLevel2: QueLevel2, fillBlankIndex: inout Int, isResult: Bool) {
        if element.tagName != "thead" {
            return nil
        }
        var trModelArr: [EQTableTrModel] = []
        for itemElement in (element.children as? [TFHppleElement]) ?? [] {
            if itemElement.tagName != "tr" {
                continue
            }
            if let model = EQTableTrModel(element: itemElement, queLevel2: queLevel2, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
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
    
    init?(element: TFHppleElement, queLevel2: QueLevel2, fillBlankIndex: inout Int, isResult: Bool) {
        if element.tagName != "tr" {
            return nil
        }
        var tdModelArr: [EQTableTdModel] = []
        for itemElement in (element.children as? [TFHppleElement]) ?? [] {
            if itemElement.tagName == "td" {
                if let model = EQTableTdModel(element: itemElement, queLevel2: queLevel2, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
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
    
    let fontSize: CGFloat
    
    let backgroundColor: UIColor
    
    let boardColor: UIColor
    
    let boardWidth: CGFloat
    
    let baselineOffset: Int
    
    init(fontSize: CGFloat = 14,
         backgroundColor: UIColor = .white,
         boardColor: UIColor = .black,
         boardWidth: CGFloat = 0.5,
         baselineOffset: Int = 5) {
        self.fontSize = fontSize
        self.backgroundColor = backgroundColor
        self.boardColor = boardColor
        self.boardWidth = boardWidth
        self.baselineOffset = baselineOffset
    }
    
    static let contentModel: EQTableConfig = .init()
    
    static let headConfig: EQTableConfig = .init(fontSize: 18)
}

class EQTableTdModel: NSObject {
    
    // MARK: - 比例系数
    var xNum: Int = 0
    
    var yNum: Int = 0
    
    // 跨列
    var widthNum: Int
    // 跨行
    var heightNum: Int
    
    // MARK: - 计算的实际位置
    var x: CGFloat = 0
    
    var y: CGFloat = 0
    
    var width: CGFloat = 0
    
    var height: CGFloat = 0
    // 是否该行最后一个
    var isLast: Bool = false
    
    var configModel: EQTableConfig = .contentModel
    
    let isResult: Bool
    
    // MARK: - 填空需要
    let queLevel2: QueLevel2
    // 填空偏移
    let fillBlankIndexOffset: Int
    
    var allAttrArr: [NSMutableAttributedString]
    
    var fillBlankAttrArr: [NSMutableAttributedString]
    
    var resultAttributed: NSMutableAttributedString
    
    lazy var paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 5
        return paragraphStyle
    }()
    
    // 该整体的哪一个填空
    var focunsIndex: Int? {
        didSet {
            if let focunsIndex = oldValue, focunsIndex < fillBlankAttrArr.count {
                if getAnswer(index: fillBlankIndexOffset + focunsIndex) == nil {
                    let newFillBlankStr = NSMutableAttributedString.emptyFillBlankAttrWithIcon(index: fillBlankIndexOffset + focunsIndex, baselineOffset: configModel.baselineOffset)
                    let oldFillBlankStr = fillBlankAttrArr[focunsIndex]
                    let itemInAllIndex = (allAttrArr as NSArray).index(of: oldFillBlankStr)
                    fillBlankAttrArr[focunsIndex] = newFillBlankStr
                    allAttrArr[itemInAllIndex] = newFillBlankStr
                }
                fillBlankAttrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor.black, range: .init(location: 0, length: fillBlankAttrArr[focunsIndex].length))
            }
            if let focunsIndex = focunsIndex, focunsIndex < fillBlankAttrArr.count  {
                if getAnswer(index: fillBlankIndexOffset + focunsIndex) == nil {
                    fillBlankAttrArr[focunsIndex].replaceCharacters(in: .init(location: 1, length: 1), with: "⌘")
                }
                fillBlankAttrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor(hex: 0x2F81FB), range: .init(location: 0, length: fillBlankAttrArr[focunsIndex].length))
            }
            makeResultAttr()
        }
    }
    
    var updateBlock: (() -> Void)?
    
    init?(element: TFHppleElement, queLevel2: QueLevel2, fillBlankIndex: inout Int, isResult: Bool) {
        if element.tagName != "td" {
            return nil
        }
        self.queLevel2 = queLevel2
        self.isResult = isResult
        self.fillBlankIndexOffset = fillBlankIndex
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
        self.allAttrArr = []
        self.fillBlankAttrArr = []
        self.resultAttributed = .init()
        super.init()
        
        let firstEnd = (element.raw as NSString).range(of: ">").location + 1
        let html: String
        if firstEnd >= element.raw.count { // 为 <td/> 标签
            html = ""
        } else {
            html = (element.raw as NSString).substring(with: .init(location: firstEnd, length: element.raw.count - firstEnd - 5))
        }
        var userAnswers: [String] = []
        if queLevel2.isNormal {
            userAnswers = queLevel2.userAnswers
        } else {
            userAnswers = queLevel2.subLevel2?.map({ $0.userAnswers.first ?? "" }) ?? []
        }
        if isResult {
            var correctAnswers: [String]?
            if queLevel2.isNormal {
                correctAnswers = queLevel2.correctAnswers
            } else {
                correctAnswers = queLevel2.subLevel2?.flatMap({ $0.correctAnswers ?? [] })
            }
            resolverResult(html: html, fillBlankIndex: &fillBlankIndex, userAnswers: userAnswers, correctAnswers: correctAnswers ?? [])
        } else {
            resolver(html: html, fillBlankIndex: &fillBlankIndex, userAnswers: userAnswers)
        }
        
        // 去掉末尾换行
        while let last = allAttrArr.last, last.string.hasSuffix("\n") {
            last.replaceCharacters(in: .init(location: last.length - 1, length: 1), with: "")
            if last.string.isEmpty {
                allAttrArr.removeLast()
            }
        }
        
        makeResultAttr()
    }
    
    func setAnswer(text: String) {
        updateAttributed(text: text)
        updateStoreData(text: text)
    }
    
    func getAnswer(index: Int) -> String? {
        if queLevel2.isNormal {
            if index >= queLevel2.userAnswers.count {
                return nil
            }
            if !queLevel2.userAnswers[index].isEmpty {
                return queLevel2.userAnswers[index]
            }
        } else {
            if let qst = queLevel2.subLevel2?[index] {
                if qst.userAnswers.count <= 0 {
                    return nil
                }
                if !qst.userAnswers[0].isEmpty {
                    return qst.userAnswers[0]
                }
            }
        }
        return nil
    }
    
    private func updateAttributed(text: String) {
        guard let index = focunsIndex else {
            print("\(NSStringFromClass(Self.self)) \(#function): 未选择填空")
            return
        }
        let newFillBlank: NSMutableAttributedString!
        var text = text
        if text.isEmpty { // 若是没有内容则变为空的内容
            text = spaceStr
            newFillBlank = .emptyFillBlankAttr(index: index, baselineOffset: configModel.baselineOffset)
            newFillBlank.addAttribute(.underlineColor, value: UIColor(hex: 0x2F81FB), range: .init(location: 0, length: newFillBlank.length))
        } else {
            newFillBlank = text.fillBlankAttr(font: .systemFont(ofSize: configModel.fontSize), link: "\(snFillBlankURLPrefix)\(snSeparate)\(index)", underlineColor: .init(hex: 0x2F81FB), baselineOffset: configModel.baselineOffset)
        }
        
        let oldFillBlank = fillBlankAttrArr[index]
        let fillBlankIndex = (allAttrArr as NSArray).index(of: oldFillBlank)
        fillBlankAttrArr[index] = newFillBlank
        allAttrArr[fillBlankIndex] = newFillBlank
        
        makeResultAttr()
    }
    
    private func updateStoreData(text: String) {
        guard let index = focunsIndex else {
            print("\(NSStringFromClass(Self.self)) \(#function): 未选择填空")
            return
        }
        if queLevel2.isNormal {
            while queLevel2.userAnswers.count <= fillBlankIndexOffset + index {
                queLevel2.userAnswers.append("")
            }
            queLevel2.userAnswers[fillBlankIndexOffset + index] = text
        } else {
            if let qst = queLevel2.subLevel2?[fillBlankIndexOffset + index] {
                while qst.userAnswers.count <= 0  {
                    qst.userAnswers.append("")
                }
                qst.userAnswers[0] = text
            }
        }
    }
    
    func makeResultAttr() {
        let resultAttributed = NSMutableAttributedString()
        for itemAttrStr in allAttrArr {
            resultAttributed.append(itemAttrStr)
        }
//        resultAttributed.addAttribute(.baselineOffset, value: NSNumber(value: 5), range: .init(location: 0, length: resultAttributed.length))
        resultAttributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: resultAttributed.length))
        self.resultAttributed = resultAttributed
    }
    
    // MARK: - resolver
    func resolver(html: String, fillBlankIndex: inout Int, userAnswers: [String]) {
        let pRegex = try! NSRegularExpression(pattern: "(<blk.*?</blk>)|(<blk.*?/>)|(<p.*?</p>)")
        
        var lastIndex = 0
        
        pRegex.enumerateMatches(in: html, range: .init(location: 0, length: html.count)) { match, _, _ in
            guard let range = match?.range else { return }
            
            if range.location != lastIndex { // 有未识别内容
                let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: range.location - lastIndex))
            
                allAttrArr.append(noHandleStr.handle(fontSize: configModel.fontSize, baselineOffset: configModel.baselineOffset))
            }
            let tempStr = (html as NSString).substring(with: range)
            if tempStr.hasPrefix("<p") {
                let firstPEnd = (tempStr as NSString).range(of: ">").location + 1
                let content = (tempStr as NSString).substring(with: .init(location: firstPEnd, length: tempStr.count - firstPEnd - 4)) // 去掉<p></p>
                resolver(html: content, fillBlankIndex: &fillBlankIndex, userAnswers: userAnswers)
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: configModel.fontSize),
                ]))
            } else if tempStr.hasPrefix("<blk") {
                resolverBLK(fillBlankIndex: fillBlankIndex, userAnswers: userAnswers)
                
                fillBlankIndex += 1
            } else if tempStr.hasPrefix("<img") {
                resolverIMG(content: tempStr)
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 后面有未识别的内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))
            
            allAttrArr.append(noHandleStr.handle(fontSize: configModel.fontSize, baselineOffset: configModel.baselineOffset))
        }
    }
    
    func resolverBLK(fillBlankIndex: Int, userAnswers: [String]) {
        var enterStr = spaceStr
        var haveAnswer = false
        if fillBlankIndex < userAnswers.count, !userAnswers[fillBlankIndex].isEmpty {
            enterStr = userAnswers[fillBlankIndex]
            haveAnswer = true
        }
        
        let fillBlankAttrStr: NSMutableAttributedString!
        if haveAnswer {
            fillBlankAttrStr = enterStr.fillBlankAttr(font: .systemFont(ofSize: configModel.fontSize), link: "\(snFillBlankURLPrefix)\(snSeparate)\(fillBlankIndex)", baselineOffset: configModel.baselineOffset)
        } else {
            fillBlankAttrStr = .emptyFillBlankAttrWithIcon(index: fillBlankIndex, baselineOffset: configModel.baselineOffset)
        }
        fillBlankAttrArr.append(fillBlankAttrStr)
        allAttrArr.append(fillBlankAttrStr)
    }
    
    func resolverIMG(content: String) {
        if let imgModels = QueContentImgModel.ImgModel.load(html: content) {
            for imgModel in imgModels {
                
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: configModel.fontSize),
                ]))
                
                allAttrArr.append(.init()) // 占位
                let index = allAttrArr.count - 1
                
                SDWebImageManager.shared.loadImage(with: imgModel.src, progress: nil) { [weak self] img, data, _, _, _, url in
                    print("\(NSStringFromClass(Self.self)) \(#function) 线程: \(Thread.current) 图片链接: \(String(describing: url)) 替换下标: \(index)")
                    guard let self = self, let img = img else { return }
                    let attachment = NSTextAttachment(image: img)
                    var width = imgModel.width ?? img.size.width
                    var height = imgModel.height ?? img.size.height
                    if width > kScreenWidth - 40 {
                        height = (kScreenWidth - 40) / width * height
                        width = kScreenWidth - 40
                    }
                    attachment.bounds = .init(x: 0, y: 0, width: width, height: height)
                    
                    let imgAttr = NSMutableAttributedString(attachment: attachment)
                    
                    allAttrArr[index] = imgAttr
                    makeResultAttr()
                    
                    updateBlock?()
                }
            }
        }
    }
    
    func resolverResult(html: String, fillBlankIndex: inout Int, userAnswers: [String], correctAnswers: [String]) {
        let pRegex = try! NSRegularExpression(pattern: "(<blk.*?</blk>)|(<blk.*?/>)|(<p.*?</p>)")
        
        var lastIndex = 0
        
        pRegex.enumerateMatches(in: html, range: .init(location: 0, length: html.count)) { match, _, _ in
            guard let range = match?.range else { return }
            
            if range.location != lastIndex { // 有未识别内容
                let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: range.location - lastIndex))
            
                allAttrArr.append(noHandleStr.handle(fontSize: configModel.fontSize, baselineOffset: configModel.baselineOffset))
            }
            let tempStr = (html as NSString).substring(with: range)
            if tempStr.hasPrefix("<p") {
                let firstPEnd = (tempStr as NSString).range(of: ">").location + 1
                let content = (tempStr as NSString).substring(with: .init(location: firstPEnd, length: tempStr.count - firstPEnd - 4)) // 去掉<p></p>
                resolverResult(html: content, fillBlankIndex: &fillBlankIndex, userAnswers: userAnswers, correctAnswers: correctAnswers)
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: configModel.fontSize),
                ]))
            } else if tempStr.hasPrefix("<blk") {
                resolverResultBLK(fillBlankIndex: fillBlankIndex, userAnswers: userAnswers, correctAnswers: correctAnswers)
                
                fillBlankIndex += 1
            } else if tempStr.hasPrefix("<img") {
                resolverIMG(content: tempStr)
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 后面有未识别的内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))
            
            allAttrArr.append(noHandleStr.handle(fontSize: configModel.fontSize, baselineOffset: configModel.baselineOffset))
        }
    }
    
    func resolverResultBLK(fillBlankIndex: Int, userAnswers: [String], correctAnswers: [String]) {
        var enterStr = spaceStr
        var haveAnswer = false
        if fillBlankIndex < userAnswers.count, !userAnswers[fillBlankIndex].isEmpty {
            enterStr = userAnswers[fillBlankIndex]
            haveAnswer = true
        }
        
        let fillBlankAttrStr: NSMutableAttributedString!
        if haveAnswer {
            fillBlankAttrStr = enterStr.fillBlankAttr(font: .systemFont(ofSize: configModel.fontSize), link: "\(snFillBlankURLPrefix)\(snSeparate)\(fillBlankIndex)", baselineOffset: configModel.baselineOffset)
        } else {
            fillBlankAttrStr = .emptyFillBlankAttr(index: fillBlankIndex, baselineOffset: configModel.baselineOffset)
        }
        
        var imgStr = "wrong_img"
        if haveAnswer, fillBlankIndex < correctAnswers.count {
            let correctAnswer = correctAnswers[fillBlankIndex]
            imgStr = enterStr.removeSpace() == correctAnswer.removeSpace() ? "right_img" : "wrong_img"
        }
        let attachment = NSTextAttachment()
        attachment.image = .init(named: imgStr)
        attachment.bounds = .init(x: 0, y: 0, width: 20, height: 20)
        fillBlankAttrStr.append(.init(attachment: attachment))
        
        fillBlankAttrArr.append(fillBlankAttrStr)
        allAttrArr.append(fillBlankAttrStr)
    }
}


