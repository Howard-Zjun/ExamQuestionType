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

    let tableModel: TableModel
    
    weak var delegate: QueContentModelDelegate? {
        didSet {
            for trModel in tableModel.expansionTrModels {
                trModel.updateBlock = { [weak self] in
                    guard let self = self else { return }
                    delegate?.contentDidChange(model: self)
                }
            }
        }
    }
    
    init?(question: QuestionNode, node: HTMLNode, isResult: Bool = false) {
        guard let tableModel = TableModel(node: node, question: question, isResult: isResult) else {
            return nil
        }
        tableModel.adjustSize(contentWidth: kScreenWidth - contentInset.left - contentInset.right)
        self.tableModel = tableModel
        if let last = tableModel.expansionTrModels.last {
            self.estimatedHeight = last.y + last.height
        } else {
            self.estimatedHeight = CGFloat(tableModel.rowCount) * 55
        }
    }
    
    /// 兼容仍传入 HTML 的填空入口；已有节点时应直接使用 node 初始化，避免重复解析。
    convenience init?(question: QuestionNode, html: String, isResult: Bool = false) {
        guard let document = try? HTMLDocument(html: html),
              let node = document.firstElement(named: "table") else { return nil }
        self.init(question: question, node: node, isResult: isResult)
    }

    convenience init?(question: QuestionNode, isResult: Bool = false) {
        guard let content = question.content else {
            return nil
        }
        self.init(question: question, html: content, isResult: isResult)
    }
}

class TableModel: NSObject {
    
    let theadModel: TableHeadModel?
    
    let trModels: [TableTrModel]
    
    var expansionTrModels: [TableTdModel] {
        trModels.flatMap { $0.tdModelArr }
    }
    
    var maxColCount: Int

    var rowCount: Int
    
    init?(node: HTMLNode, question: QuestionNode, isResult: Bool) {
        guard node.kind == .element, node.name == "table" else { return nil }
        var theadModel: TableHeadModel?
        var trModelArr: [TableTrModel] = []
        var fillBlankIndex = 0

        for child in node.children {
            if let model = TableHeadModel(node: child, question: question, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
                theadModel = model
            } else if let model = TableTrModel(node: child, question: question, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
                trModelArr.append(model)
            } else if child.name == "tbody" || child.name == "tfoot" {
                for row in child.children {
                    if let model = TableTrModel(node: row, question: question, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
                        trModelArr.append(model)
                    }
                }
            }
        }
        guard !trModelArr.isEmpty else { return nil }
        self.theadModel = theadModel
        self.trModels = trModelArr
        self.maxColCount = 1
        self.rowCount = 1

        super.init()

        calMaxRowCount()
        
        calMaxColCount()
        
        // 将单元所在位置修正，下面是数据都正确的处理逻辑，没有应对异常的处理
        
        // 每列剩余的占用行数；处理当前行时包含当前行，行末统一递减。
        var barrierArr: [Int] = .init(repeating: 0, count: maxColCount)
        
        for (trIndex, trModel) in ((theadModel?.trModelArr ?? []) + trModelArr).enumerated() {
            var left = 0 // 当前等待修正的下标
            var right = 0 // 指向的下标
            while right < maxColCount && left < trModel.tdModelArr.count {
                let model = trModel.tdModelArr[left]
                
                var haveBarrier = false
                // 查找期间只读取障碍，避免重复检查同一列时提前释放跨行占用。
                for index in 0..<model.columnSpan {
                    if right + index >= barrierArr.count {
                        haveBarrier = true
                        break
                    }
                    if barrierArr[right + index] > 0 {
                        haveBarrier = true
                    }
                }
                
                if haveBarrier { // 有障碍时，向后移动一列继续查找。
                    right += 1
                } else { // 没有障碍可以修正位置
                    trModel.tdModelArr[left].rowIndex = trIndex
                    trModel.tdModelArr[left].columnIndex = right
                    
                    // 记录包含当前行的占用，行末与其他列一起递减。
                    for index in 0..<model.columnSpan {
                        if right + index >= barrierArr.count {
                            break
                        }
                        barrierArr[right + index] = model.rowSpan
                    }
                    left += 1
                    
                    right += model.columnSpan
                }
            }
            barrierArr = barrierArr.map { max(0, $0 - 1) }
            print(trModel.tdModelArr.map({"xNum: \($0.columnIndex) yNum: \($0.rowIndex) widthNum: \($0.columnSpan) heightNum: \($0.rowSpan)"}))
            print("------")
        }
    }
    
    func calMaxRowCount() {
        // 计算最大行数
        var rowCount = 0
        if let theadModel = theadModel {
            for trModel in theadModel.trModelArr {
                rowCount += 1
                for tdModel in trModel.tdModelArr {
                    tdModel.configModel = .headConfig
                }
            }
        }
        for _ in trModels {
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
        for (trIndex, trModel) in ((theadModel?.trModelArr ?? []) + trModels).enumerated() {
            
            // 处理每行里的跨列，填充跨行后，行的宽度
            for tdModel in trModel.tdModelArr {
                for i in 0..<tdModel.rowSpan {
                    maxColArr[trIndex + i] += tdModel.columnSpan
                }
            }
            
            maxColCount = max(maxColCount, maxColArr[trIndex])
        }
        
        print("\(NSStringFromClass(Self.self)) \(#function) 最大列数: \(maxColCount)")
        self.maxColCount = maxColCount
    }
    
    /// 单元大小适应
    func adjustSize(contentWidth: CGFloat) {
        var arr: [[TableTdModel]] = .init(repeating: [], count: rowCount)
        
        for trModel in (theadModel?.trModelArr ?? []) + trModels {
            for tdModel in trModel.tdModelArr {
                arr[tdModel.rowIndex + tdModel.rowSpan - 1].append(tdModel)
            }
        }
        
        var maxY: CGFloat = 0
        let colSpan = floor(contentWidth / CGFloat(maxColCount))
        for (trIndex, trModel) in ((theadModel?.trModelArr ?? []) + trModels).enumerated() {
            var maxContentHeight: CGFloat = 0
            for tdModel in trModel.tdModelArr {
                tdModel.x = CGFloat(tdModel.columnIndex) * colSpan
                tdModel.y = maxY
                if tdModel.isLast {
                    tdModel.width = contentWidth - tdModel.x
                } else {
                    tdModel.width = CGFloat(tdModel.columnSpan) * colSpan
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

class TableHeadModel: NSObject {

    let trModelArr: [TableTrModel]
    
    init?(node: HTMLNode, question: QuestionNode, fillBlankIndex: inout Int, isResult: Bool) {
        if node.kind != .element || node.name != "thead" {
            return nil
        }
        var trModelArr: [TableTrModel] = []
        for child in node.children {
            if child.name != "tr" {
                continue
            }
            if let model = TableTrModel(node: child, question: question, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
                trModelArr.append(model)
            }
        }
        if trModelArr.isEmpty {
            return nil
        }
        self.trModelArr = trModelArr
    }
}

class TableTrModel: NSObject {

    
    let tdModelArr: [TableTdModel]
    
    init?(node: HTMLNode, question: QuestionNode, fillBlankIndex: inout Int, isResult: Bool) {
        if node.kind != .element || node.name != "tr" {
            return nil
        }
        var tdModelArr: [TableTdModel] = []
        for child in node.children {
            if child.name == "td" {
                if let model = TableTdModel(node: child, question: question, fillBlankIndex: &fillBlankIndex, isResult: isResult) {
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

class TableTdModel: NSObject {
    
    /// 根据跨行跨列调整后，合适的起始单元
    var columnIndex: Int = 0
    
    var rowIndex: Int = 0
    
    // 跨列
    var columnSpan: Int
    // 跨行
    var rowSpan: Int
    
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
    let question: QuestionNode
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
    
    init?(node: HTMLNode, question: QuestionNode, fillBlankIndex: inout Int, isResult: Bool) {
        if node.kind != .element || node.name != "td" {
            return nil
        }
        self.question = question
        self.isResult = isResult
        self.fillBlankIndexOffset = fillBlankIndex
        // 从原始节点读取合并属性，未提供或无法转换时默认为 1。
        self.rowSpan = node.attribute(named: "rowspan").flatMap { Int($0) } ?? 1
        self.columnSpan = node.attribute(named: "colspan").flatMap { Int($0) } ?? 1
        self.allAttrArr = []
        self.fillBlankAttrArr = []
        self.resultAttributed = .init()
        super.init()
        
        var userAnswers: [String] = []
        if question.isNormal {
            userAnswers = question.userAnswers
        } else {
            userAnswers = question.subquestions?.map({ $0.userAnswers.first ?? "" }) ?? []
        }
        let correctAnswers: [String]
        if question.isNormal {
            correctAnswers = question.correctAnswers ?? []
        } else {
            correctAnswers = question.subquestions?.flatMap { $0.correctAnswers ?? [] } ?? []
        }
        resolve(node, fillBlankIndex: &fillBlankIndex, userAnswers: userAnswers, correctAnswers: correctAnswers)

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
        if question.isNormal {
            if index >= question.userAnswers.count {
                return nil
            }
            if !question.userAnswers[index].isEmpty {
                return question.userAnswers[index]
            }
        } else {
            if let qst = question.subquestions?[index] {
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
        if question.isNormal {
            while question.userAnswers.count <= fillBlankIndexOffset + index {
                question.userAnswers.append("")
            }
            question.userAnswers[fillBlankIndexOffset + index] = text
        } else {
            if let qst = question.subquestions?[fillBlankIndexOffset + index] {
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
    private func appendText(_ text: String, tags: [String]) {
        guard !text.isEmpty else { return }
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: configModel.fontSize),
            .baselineOffset: NSNumber(value: configModel.baselineOffset)
        ]
        if tags.contains("u") {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = UIColor.black
        }
        if tags.contains("i") || tags.contains("em") {
            attributes[.obliqueness] = NSNumber(value: 0.5)
        }
        if tags.contains("b") || tags.contains("strong") {
            attributes[.font] = UIFont.systemFont(ofSize: configModel.fontSize, weight: .bold)
        }
        if tags.contains("sup") {
            attributes[.font] = UIFont.systemFont(ofSize: configModel.fontSize * 0.5)
            attributes[.baselineOffset] = NSNumber(value: configModel.baselineOffset + Int(ceil(configModel.fontSize * 1.5)))
        }
        if tags.contains("sub") {
            attributes[.font] = UIFont.systemFont(ofSize: configModel.fontSize * 0.5)
        }
        allAttrArr.append(NSMutableAttributedString(string: text, attributes: attributes))
    }

    /// 同一棵单元格子树同时支持作答与结果模式，所有空位共用外部传入的全局索引。
    private func resolve(_ node: HTMLNode, fillBlankIndex: inout Int, userAnswers: [String], correctAnswers: [String], tags: [String] = []) {
        if node.kind == .text || node.kind == .cdata {
            appendText(node.text ?? "", tags: tags)
            return
        }
        guard node.kind == .element else { return }
        switch node.name {
        case "blk":
            if isResult {
                resolverResultBLK(fillBlankIndex: fillBlankIndex, userAnswers: userAnswers, correctAnswers: correctAnswers)
            } else {
                resolverBLK(fillBlankIndex: fillBlankIndex, userAnswers: userAnswers)
            }
            fillBlankIndex += 1
        case "img":
            resolverIMG(node: node)
        case "br":
            appendText("\n", tags: tags)
        case "head", "script", "style":
            break
        default:
            let inlineTags: Set<String> = ["b", "strong", "i", "em", "u", "a", "sup", "sub"]
            let childTags = node.name.flatMap { inlineTags.contains($0) ? tags + [$0] : nil } ?? tags
            for child in node.children {
                resolve(child, fillBlankIndex: &fillBlankIndex, userAnswers: userAnswers, correctAnswers: correctAnswers, tags: childTags)
            }
            if node.name == "p" {
                appendText("\n", tags: [])
            }
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
    
    private func resolverIMG(node: HTMLNode) {
        guard let src = node.attribute(named: "src"), let url = URL(string: src) else { return }
        let imageWidth = node.attribute(named: "width").flatMap { Float($0) }.map { CGFloat($0) }
        let imageHeight = node.attribute(named: "height").flatMap { Float($0) }.map { CGFloat($0) }
        appendText("\n", tags: [])
        allAttrArr.append(.init()) // 保留图片的位置，异步加载后替换。
        let index = allAttrArr.count - 1

        SDWebImageManager.shared.loadImage(with: url, progress: nil) { [weak self] image, _, _, _, _, _ in
            guard let self = self, let image = image else { return }
            let attachment = NSTextAttachment(image: image)
            var width = imageWidth ?? image.size.width
            var height = imageHeight ?? image.size.height
            if width > kScreenWidth - 40 {
                height = (kScreenWidth - 40) / width * height
                width = kScreenWidth - 40
            }
            attachment.bounds = .init(x: 0, y: 0, width: width, height: height)
            allAttrArr[index] = NSMutableAttributedString(attachment: attachment)
            makeResultAttr()
            updateBlock?()
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


