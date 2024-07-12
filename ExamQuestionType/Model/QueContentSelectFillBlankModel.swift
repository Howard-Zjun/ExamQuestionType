//
//  QueContentSelectFillBlankModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/13.
//

import UIKit

class QueContentSelectFillBlankModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentSelectFillBlankCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    var estimatedHeight: CGFloat?

    let queLevel2: QueLevel2
    
    var fillBlankAttrArr: [NSMutableAttributedString]
    
    var allAttrArr: [NSMutableAttributedString]
    
    var resultAttributed: NSMutableAttributedString
    
    lazy var paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 5
        return paragraphStyle
    }()
    
    // 选项
    let options: [[String]]
    
    weak var delegate: QueContentModelDelegate?
    
    var focunsIndex: Int? {
        didSet {
            if let focunsIndex = oldValue, focunsIndex < fillBlankAttrArr.count {
                if getStrAnswer(index: focunsIndex) == nil { // 聚焦在没有答案的填空消失，添加缺省图标
                    let newFillBlankStr = NSMutableAttributedString.emptyFillBlankAttrStr(index: focunsIndex, paragraphStyle: paragraphStyle)
                    let oldFillBlankStr = fillBlankAttrArr[focunsIndex]
                    let itemInAllIndex = (allAttrArr as NSArray).index(of: oldFillBlankStr)
                    fillBlankAttrArr[focunsIndex] = newFillBlankStr
                    allAttrArr[itemInAllIndex] = newFillBlankStr
                }
                fillBlankAttrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor.black, range: .init(location: 0, length: fillBlankAttrArr[focunsIndex].length))
            }
            if let focunsIndex = focunsIndex, focunsIndex < fillBlankAttrArr.count  {
                if getStrAnswer(index: focunsIndex) == nil { // 聚焦在没有答案的填空出现，清掉缺省图标
                    fillBlankAttrArr[focunsIndex].replaceCharacters(in: .init(location: 1, length: 1), with: "⌘")
                    fillBlankAttrArr[focunsIndex].addAttribute(.foregroundColor, value: UIColor.clear, range: .init(location: 0, length: fillBlankAttrArr[focunsIndex].length))
                }
                fillBlankAttrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor(hex: 0x2F81FB), range: .init(location: 0, length: fillBlankAttrArr[focunsIndex].length))
            }
            makeResultAttr()
        }
    }
    
    var isResult: Bool
    
    init?(queLevel2: QueLevel2, isResult: Bool = false) {
        let no = queLevel2.no ?? ""
        let content = queLevel2.content ?? ""
        let html = no + content
        guard queLevel2.type == .SelectFillBlank, !html.isEmpty else {
            return nil
        }
        
        self.queLevel2 = queLevel2
        var options: [[String]] = []
        if queLevel2.isNormal {
            for _ in 0..<(queLevel2.correctAnswers?.count ?? 0) {
                options.append(queLevel2.options ?? [])
            }
            
        } else {
            for item in queLevel2.subLevel2 ?? [] {
                options.append(item.options ?? [])
            }
        }
        self.options = options
        self.allAttrArr = []
        self.fillBlankAttrArr = []
        self.resultAttributed = NSMutableAttributedString()
        self.isResult = isResult
        super.init()
        
        var userAnswers: [String] = []
        if queLevel2.isNormal {
            userAnswers = queLevel2.userAnswers
        } else {
            for item in queLevel2.subLevel2 ?? [] {
                userAnswers.append(item.userAnswers.first ?? "")
            }
        }
        if isResult {
            var correctAnswers: [String]?
            if queLevel2.isNormal {
                correctAnswers = queLevel2.correctAnswers
            } else {
                correctAnswers = queLevel2.subLevel2?.flatMap({ $0.correctAnswers ?? [] })
            }
            resolverResult(html: html, userAnswers: userAnswers, correctAnswers: correctAnswers ?? [])
        } else {
            resolver(html: html, userAnswers: userAnswers)
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
    
    func setAnswer(optionIndex: Int, index: Int) {
        if queLevel2.isNormal {
            while let count = queLevel2.correctAnswers?.count, queLevel2.userAnswers.count < count {
                queLevel2.userAnswers.append("")
            }
            queLevel2.userAnswers[index] = Tool.positionToLetter(position: optionIndex)
        } else {
            if let item = queLevel2.subLevel2?[index] {
                while let count = item.correctAnswers?.count, item.userAnswers.count < count {
                    item.userAnswers.append("")
                }
                item.userAnswers[0] = Tool.positionToLetter(position: optionIndex)
            }
        }
        
        fillBlankAttrArr[index].replaceCharacters(in: .init(location: 1, length: 1), with: Tool.positionToLetter(position: optionIndex))
        fillBlankAttrArr[index].addAttribute(.foregroundColor, value: UIColor.blue, range: .init(location: 1, length: 1))
        makeResultAttr()
    }
    
    func getAnswer(index: Int) -> Int? {
        if let str = getStrAnswer(index: index) {
            return Tool.letterToPosition(letter: str)
        } else {
            return nil
        }
    }
    
    func getStrAnswer(index: Int) -> String? {
        if queLevel2.isNormal {
            if index >= queLevel2.userAnswers.count {
                return nil
            }
            if !queLevel2.userAnswers[index].isEmpty {
                return queLevel2.userAnswers[index]
            } else {
                return nil
            }
        } else {
            if index >= queLevel2.subLevel2?.count ?? 0 {
                return nil
            }
            if let str = queLevel2.subLevel2?[index].userAnswers.first, !str.isEmpty {
                return str
            }
        }
        return nil
    }
    
    func makeResultAttr() {
        let resultAttributed = NSMutableAttributedString()
        for itemAttrStr in allAttrArr {
            resultAttributed.append(itemAttrStr)
        }
        resultAttributed.addAttribute(.baselineOffset, value: NSNumber(value: 5), range: .init(location: 0, length: resultAttributed.length))
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.paragraphSpacing = 5
        resultAttributed.addAttribute(.paragraphStyle, value: style, range: .init(location: 0, length: resultAttributed.length))
        self.resultAttributed = resultAttributed
    }

    // MARK: - resolver
    func resolver(html: String, userAnswers: [String]) {
        let pRegex = try! NSRegularExpression(pattern: "(<blk.*?</blk>)|(<img.*?>)|(<p.*?</p>)")
        
        var lastIndex = 0
        
        pRegex.enumerateMatches(in: html, range: .init(location: 0, length: html.count)) { match, _, _ in
            guard let range = match?.range else { return }
            
            if range.location != lastIndex { // 有未识别内容
                let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: range.location - lastIndex))
            
                allAttrArr.append(noHandleStr.handle(type: [.uTag, .iTag, .bTag, .br, .aTag, .strongTag], fontSize: 18, paragraphStyle: paragraphStyle))
            }
            let tempStr = (html as NSString).substring(with: range)
            if tempStr.hasPrefix("<p") {
                let firstPEnd = (tempStr as NSString).range(of: ">").location + 1
                let content = (tempStr as NSString).substring(with: .init(location: firstPEnd, length: tempStr.count - firstPEnd - 4)) // 去掉<p></p>
                resolver(html: content, userAnswers: userAnswers)
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: 18),
                    .paragraphStyle : paragraphStyle,
                ]))
            } else if tempStr.hasPrefix("<blk") {
                let fillBlankIndex = fillBlankAttrArr.count
                resolverBLK(fillBlankIndex: fillBlankIndex, userAnswers: userAnswers)
            } else if tempStr.hasPrefix("<img") {
                resolverIMG(content: tempStr)
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 后面有未识别的内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))
            
            allAttrArr.append(noHandleStr.handle(type: [.uTag, .iTag, .bTag, .br, .aTag, .strongTag], fontSize: 18, paragraphStyle: paragraphStyle))
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
            fillBlankAttrStr = enterStr.fillBlankAttr(font: .systemFont(ofSize: 18), link: "\(snFillBlankURLPrefix)\(snSeparate)\(fillBlankIndex)", paragraphStyle: paragraphStyle)
        } else {
            fillBlankAttrStr = .emptyFillBlankAttrStr(index: fillBlankIndex, paragraphStyle: paragraphStyle)
        }
        fillBlankAttrArr.append(fillBlankAttrStr)
        allAttrArr.append(fillBlankAttrStr)
    }
    
    func resolverIMG(content: String) {
        if let imgModels = QueContentImgModel.ImgModel.load(html: content) {
            for imgModel in imgModels {
                
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: 18),
                    .paragraphStyle : paragraphStyle,
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
                    
                    delegate?.contentDidChange(model: self)
                }
            }
        }
    }
    
    func resolverResult(html: String, userAnswers: [String], correctAnswers: [String]) {
        let pRegex = try! NSRegularExpression(pattern: "(<blk.*?</blk>)|(<img.*?>)|(<p.*?</p>)")
        
        var lastIndex = 0
        
        pRegex.enumerateMatches(in: html, range: .init(location: 0, length: html.count)) { match, _, _ in
            guard let range = match?.range else { return }
            
            if range.location != lastIndex { // 有未识别内容
                let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: range.location - lastIndex))
            
                allAttrArr.append(noHandleStr.handle(type: [.uTag, .iTag, .bTag, .br, .aTag, .strongTag], fontSize: 18, paragraphStyle: paragraphStyle))
            }
            let tempStr = (html as NSString).substring(with: range)
            if tempStr.hasPrefix("<p") {
                let firstPEnd = (tempStr as NSString).range(of: ">").location + 1
                let content = (tempStr as NSString).substring(with: .init(location: firstPEnd, length: tempStr.count - firstPEnd - 4)) // 去掉<p></p>
                resolverResult(html: content, userAnswers: userAnswers, correctAnswers: correctAnswers)
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: 18),
                    .paragraphStyle : paragraphStyle,
                ]))
            } else if tempStr.hasPrefix("<blk") {
                let fillBlankIndex = fillBlankAttrArr.count
                resolverResultBLK(fillBlankIndex: fillBlankIndex, userAnswers: userAnswers, correctAnswers: correctAnswers)
            } else if tempStr.hasPrefix("<img") {
                resolverIMG(content: tempStr)
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 后面有未识别的内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))
            
            allAttrArr.append(noHandleStr.handle(type: [.uTag, .iTag, .bTag, .br, .aTag, .strongTag], fontSize: 18, paragraphStyle: paragraphStyle))
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
            fillBlankAttrStr = enterStr.fillBlankAttr(font: .systemFont(ofSize: 18), link: "\(snFillBlankURLPrefix)\(snSeparate)\(fillBlankIndex)", paragraphStyle: paragraphStyle)
        } else {
            fillBlankAttrStr = .emptyFillBlankAttrStr(index: fillBlankIndex, paragraphStyle: paragraphStyle, needEmptyPlacehold: false)
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
