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
    
    var fillBlankAttrStrArr: [NSMutableAttributedString]
    
    var allAttrStrArr: [NSMutableAttributedString]
    
    var resultAttributed: NSMutableAttributedString
    
    // 选项
    let options: [String]
    
    var delegate: QueContentModelDelegate?
    
    var focunsIndex: Int? {
        didSet {
            if let focunsIndex = oldValue, focunsIndex < fillBlankAttrStrArr.count {
                if getStrAnswer(index: focunsIndex) == nil { // 聚焦在没有答案的填空消失，添加缺省图标
                    let newFillBlankStr = NSAttributedString.emptyFillBlankAttrStr(index: focunsIndex)
                    let oldFillBlankStr = fillBlankAttrStrArr[focunsIndex]
                    let itemInAllIndex = (allAttrStrArr as NSArray).index(of: oldFillBlankStr)
                    fillBlankAttrStrArr[focunsIndex] = newFillBlankStr
                    allAttrStrArr[itemInAllIndex] = newFillBlankStr
                }
                fillBlankAttrStrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor.black, range: .init(location: 0, length: fillBlankAttrStrArr[focunsIndex].length))
            }
            if let focunsIndex = focunsIndex, focunsIndex < fillBlankAttrStrArr.count  {
                if getStrAnswer(index: focunsIndex) == nil { // 聚焦在没有答案的填空出现，清掉缺省图标
                    fillBlankAttrStrArr[focunsIndex].replaceCharacters(in: .init(location: 1, length: 1), with: "⌘")
                    fillBlankAttrStrArr[focunsIndex].addAttribute(.foregroundColor, value: UIColor.clear, range: .init(location: 0, length: fillBlankAttrStrArr[focunsIndex].length))
                }
                fillBlankAttrStrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor.blue, range: .init(location: 0, length: fillBlankAttrStrArr[focunsIndex].length))
            }
            makeResultAttr()
        }
    }
    
    init?(queLevel2: QueLevel2) {
        guard queLevel2.type == .Select, let options = queLevel2.options else {
            return nil
        }
        self.queLevel2 = queLevel2
        
        self.options = options
        self.allAttrStrArr = []
        self.fillBlankAttrStrArr = []
        self.resultAttributed = NSMutableAttributedString()
        super.init()
        
        guard let content = queLevel2.content, let data = content.data(using: .utf8) else {
            return nil
        }
        let hpple = TFHpple(data: data, isXML: false)
        guard let elements = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement] else {
            return nil
        }
        
        var fillBlankIndex = 0
        for element in elements {
            for item in (element.children as? [TFHppleElement]) ?? [] {
                if item.tagName == "text" {
                    let attr = item.content.handleUIB(fontSize: 18)
                    attr.addAttributes([
                        .foregroundColor : UIColor.black
                    ], range: .init(location: 0, length: attr.length))
                    allAttrStrArr.append(attr)
                } else if item.tagName == "img" {
                    if let imgModels = QueContentImgModel.ImgModel.load(html: item.raw) {
                        
                        for imgModel in imgModels {
                            allAttrStrArr.append(NSMutableAttributedString()) // 占位
                            let index = allAttrStrArr.count
                            SDWebImageManager.shared.loadImage(with: imgModel.src, progress: nil) { [weak self] img, data, _, _, _, _ in
                                guard let self = self, let img = img else { return }
                                let attachment = NSTextAttachment(image: img)
                                let width = imgModel.width ?? img.size.width
                                let height = imgModel.height ?? img.size.height
                                attachment.bounds = .init(x: 0, y: 0, width: width, height: height)
                                
                                let imgAttr = NSMutableAttributedString(attachment: attachment)
                                
                                allAttrStrArr[index] = imgAttr
                                makeResultAttr()
                                
                                delegate?.contentDidChange(model: self)
                            }
                        }
                    }
                } else if item.tagName == "blk" {
                    var enterStr = spaceStr
                    var haveAnswer = false
                    if fillBlankIndex < queLevel2.userAnswers.count, !queLevel2.userAnswers[fillBlankIndex].isEmpty {
                        enterStr = queLevel2.userAnswers[fillBlankIndex]
                        haveAnswer = true
                    }
                    
                    let fillBlankAttrStr: NSMutableAttributedString!
                    if haveAnswer {
                        fillBlankAttrStr = NSMutableAttributedString(string: enterStr, attributes: [
                            .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                            .underlineColor : UIColor.black,
                            .link : "\(snFillBlankURLPrefix)\(snSeparate)\(fillBlankIndex)",
                            .font : UIFont.systemFont(ofSize: 18),
                            .foregroundColor : UIColor.clear,
                        ])
                        fillBlankAttrStr.addAttribute(.foregroundColor, value: UIColor.blue, range: .init(location: 1, length: 1))
                    } else {
                        fillBlankAttrStr = NSAttributedString.emptyFillBlankAttrStr(index: fillBlankIndex)
                    }
                    
                    fillBlankIndex += 1
                    
                    fillBlankAttrStrArr.append(fillBlankAttrStr)
                    allAttrStrArr.append(fillBlankAttrStr)
                }
            }
            // 换行样式
            let itemAttr = "\n".handleUIB(fontSize: 18)
            itemAttr.addAttributes([
                .foregroundColor : UIColor.black,
                .paragraphStyle : style
            ], range: .init(location: 0, length: itemAttr.length))
            allAttrStrArr.append(itemAttr)
        }
        
        let resultAttributed = NSMutableAttributedString()
        for itemAttrStr in allAttrStrArr {
            resultAttributed.append(itemAttrStr)
        }
        resultAttributed.addAttribute(.baselineOffset, value: NSNumber(value: 5), range: .init(location: 0, length: resultAttributed.length))
        self.resultAttributed = resultAttributed
    }
    
    func setAnswer(optionIndex: Int, index: Int) {
        while let count = queLevel2.correctAnswers?.count, queLevel2.userAnswers.count < count {
            queLevel2.userAnswers.append("")
        }
        queLevel2.userAnswers[index] = Tool.positionToLetter(position: optionIndex)
        
        fillBlankAttrStrArr[index].replaceCharacters(in: .init(location: 1, length: 1), with: Tool.positionToLetter(position: optionIndex))
        fillBlankAttrStrArr[index].addAttribute(.foregroundColor, value: UIColor.blue, range: .init(location: 1, length: 1))
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
        for itemAttrStr in allAttrStrArr {
            resultAttributed.append(itemAttrStr)
        }
        resultAttributed.addAttribute(.baselineOffset, value: NSNumber(value: 5), range: .init(location: 0, length: resultAttributed.length))
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.paragraphSpacing = 5
        resultAttributed.addAttribute(.paragraphStyle, value: style, range: .init(location: 0, length: resultAttributed.length))
        self.resultAttributed = resultAttributed
    }
}
