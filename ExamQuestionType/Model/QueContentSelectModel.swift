//
//  QueContentSelectModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/13.
//

import UIKit

class QueContentSelectModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentSelectCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let queLevel2: QueLevel2
    
    var fillBlankAttrArr: [NSMutableAttributedString]
    
    var allAttrArr: [NSMutableAttributedString]
    
    var resultAttributed: NSMutableAttributedString
    
    // 选项
    let options: [String]
    
    var delegate: QueContentModelDelegate?
    
    var focunsIndex: Int? {
        didSet {
            if let focunsIndex = oldValue, focunsIndex < fillBlankAttrArr.count {
                if getStrAnswer(index: focunsIndex) == nil { // 聚焦在没有答案的填空消失，添加缺省图标
                    let newFillBlankStr = NSAttributedString.emptyFillBlankAttrStr(index: focunsIndex)
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
                fillBlankAttrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor.blue, range: .init(location: 0, length: fillBlankAttrArr[focunsIndex].length))
            }
            makeResultAttr()
        }
    }
    
    init?(queLevel2: QueLevel2) {
        guard queLevel2.type == .Select, let options = queLevel2.options, let html = queLevel2.content else {
            return nil
        }
        self.queLevel2 = queLevel2
        self.options = options
        self.allAttrArr = []
        self.fillBlankAttrArr = []
        self.resultAttributed = NSMutableAttributedString()
        super.init()
        
        (fillBlankAttrArr, allAttrArr) = resolver(html: html, fillBlankOffset: 0)
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
        while let count = queLevel2.correctAnswers?.count, queLevel2.userAnswers.count < count {
            queLevel2.userAnswers.append("")
        }
        queLevel2.userAnswers[index] = Tool.positionToLetter(position: optionIndex)
        
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
        if index >= queLevel2.userAnswers.count {
            return nil
        }
        if !queLevel2.userAnswers[index].isEmpty {
            return queLevel2.userAnswers[index]
        } else {
            return nil
        }
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
    
    func resolver(html: String, fillBlankOffset: Int) -> ([NSMutableAttributedString], [NSMutableAttributedString]) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 5
        
        let pRegex = try! NSRegularExpression(pattern: "(<blk.*?</blk>)|(<img.*?>)|(<p>.*?</p>)")
        
        var fillBlankAttrArr: [NSMutableAttributedString] = []
        var allAttrArr: [NSMutableAttributedString] = []
        
        var lastIndex = 0
        
        pRegex.enumerateMatches(in: html, range: .init(location: 0, length: html.count)) { match, _, _ in
            guard let range = match?.range else { return }
            if range.location != lastIndex { // 有未识别内容
                let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: range.location - lastIndex))
                
                allAttrArr.append(noHandleStr.handleUIB(fontSize: 18, paragraphStyle: paragraphStyle))
            }
            let tempStr = (html as NSString).substring(with: range)
            if tempStr.hasPrefix("<p") {
                let content = (tempStr as NSString).substring(with: .init(location: 3, length: tempStr.count - 3 - 4)) // 去掉<p></p>
                let tempRet = resolver(html: content, fillBlankOffset: fillBlankOffset + fillBlankAttrArr.count)
                fillBlankAttrArr += tempRet.0
                allAttrArr += tempRet.1
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: 18),
                    .paragraphStyle : paragraphStyle,
                ]))
            } else if tempStr.hasPrefix("<blk") {
                let fillBlankIndex = fillBlankOffset + fillBlankAttrArr.count
                var enterStr = spaceStr
                var haveAnswer = false
                if fillBlankIndex < queLevel2.userAnswers.count, !queLevel2.userAnswers[fillBlankIndex].isEmpty {
                    enterStr = queLevel2.userAnswers[fillBlankIndex]
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
            } else if tempStr.hasPrefix("<img") {
                if let imgModels = QueContentImgModel.ImgModel.load(html: tempStr) {
                    for imgModel in imgModels {
                        
                        allAttrArr.append(.init()) // 占位
                        let index = allAttrArr.count - 1
                        
                        SDWebImageManager.shared.loadImage(with: imgModel.src, progress: nil) { [weak self] img, data, _, _, _, url in
                            print("\(NSStringFromClass(Self.self)) \(#function) 线程: \(Thread.current) 图片链接: \(String(describing: url)) 替换下标: \(index)")
                            guard let self = self, let img = img else { return }
                            let attachment = NSTextAttachment(image: img)
                            let width = imgModel.width ?? img.size.width
                            let height = imgModel.height ?? img.size.height
                            attachment.bounds = .init(x: 0, y: 0, width: width, height: height)
                            
                            let imgAttr = NSMutableAttributedString(attachment: attachment)
                            
                            allAttrArr[index] = imgAttr
                            makeResultAttr()
                            
                            delegate?.contentDidChange(model: self)
                        }
                    }
                }
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 后面有未识别的内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))
            
            allAttrArr.append(noHandleStr.handleUIB(fontSize: 18, paragraphStyle: paragraphStyle))
        }
        
        return (fillBlankAttrArr, allAttrArr)
    }

}
