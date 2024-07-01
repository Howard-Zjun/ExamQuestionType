//
//  QueContentFillBlankModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/13.
//

import UIKit

let snFillBlankURLPrefix = "blank"

let snSeparate = ":"

let spaceStr = "⌘⌘⌘"

class QueContentFillBlankModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentFillBlankCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let queLevel2: QueLevel2
    
    var fillBlankAttrStrArr: [NSMutableAttributedString]
    
    var allAttrStrArr: [NSMutableAttributedString]
    
    var resultAttributed: NSMutableAttributedString
    
    var delegate: QueContentModelDelegate?
    
    var focunsIndex: Int? {
        didSet {
            if let focunsIndex = oldValue, focunsIndex < fillBlankAttrStrArr.count {
                if getAnswer(index: focunsIndex) == nil {
                    let newFillBlankStr = NSAttributedString.emptyFillBlankAttrStr(index: focunsIndex)
                    let oldFillBlankStr = fillBlankAttrStrArr[focunsIndex]
                    let itemInAllIndex = (allAttrStrArr as NSArray).index(of: oldFillBlankStr)
                    fillBlankAttrStrArr[focunsIndex] = newFillBlankStr
                    allAttrStrArr[itemInAllIndex] = newFillBlankStr
                }
                fillBlankAttrStrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor.black, range: .init(location: 0, length: fillBlankAttrStrArr[focunsIndex].length))
            }
            if let focunsIndex = focunsIndex, focunsIndex < fillBlankAttrStrArr.count  {
                if getAnswer(index: focunsIndex) == nil {
                    fillBlankAttrStrArr[focunsIndex].replaceCharacters(in: .init(location: 1, length: 1), with: "⌘")
                }
                fillBlankAttrStrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor(hex: 0x2F81FB), range: .init(location: 0, length: fillBlankAttrStrArr[focunsIndex].length))
            }
            makeResultAttr()
        }
    }
    
    init?(queLevel2: QueLevel2) {
        guard let content = queLevel2.content, let data = content.data(using: .utf8) else {
            return nil
        }
        let hpple = TFHpple(data: data, isXML: false)
        guard let elements = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement] else {
            return nil
        }
        self.allAttrStrArr = []
        self.fillBlankAttrStrArr = []
        self.resultAttributed = .init()
        self.queLevel2 = queLevel2
        super.init()
        
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
                            let index = allAttrStrArr.count - 1
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
                            .foregroundColor : UIColor.blue,
                        ])
                    } else {
                        fillBlankAttrStr = NSAttributedString.emptyFillBlankAttrStr(index: fillBlankIndex)
                    }
                    
                    fillBlankIndex += 1
                    
                    fillBlankAttrStrArr.append(fillBlankAttrStr)
                    allAttrStrArr.append(fillBlankAttrStr)
                }
            }
        }
        
        makeResultAttr()
    }
    
    func setAnswer(text: String) {
        updateAttributed(text: text)
        updateStoreData(text: text)
    }
    
    func getAnswer(index: Int) -> String? {
        while let count2 = queLevel2.correctAnswers?.count, queLevel2.userAnswers.count < count2 {
            queLevel2.userAnswers.append("")
        }
        if !queLevel2.userAnswers[index].isEmpty {
            return queLevel2.userAnswers[index]
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
            newFillBlank = NSAttributedString.emptyFillBlankAttrStr(index: index)
        } else {
            newFillBlank = .init(string: text, attributes: [
                .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor.blue,
                .link : "\(snFillBlankURLPrefix)\(snSeparate)\(index)",
                .font : UIFont.systemFont(ofSize: 18),
                .foregroundColor : UIColor.blue,
            ])
        }
        
        let oldFillBlank = fillBlankAttrStrArr[index]
        let fillBlankIndex = (allAttrStrArr as NSArray).index(of: oldFillBlank)
        fillBlankAttrStrArr[index] = newFillBlank
        allAttrStrArr[fillBlankIndex] = newFillBlank
        
        makeResultAttr()
    }
    
    private func updateStoreData(text: String) {
        guard let index = focunsIndex else {
            print("\(NSStringFromClass(Self.self)) \(#function): 未选择填空")
            return
        }
        while let count2 = queLevel2.correctAnswers?.count, queLevel2.userAnswers.count < count2 {
            queLevel2.userAnswers.append("")
        }
        print("\(NSStringFromClass(Self.self)) \(#function) text: \(text)")
        queLevel2.userAnswers[index] = text
    }
    
    func updateScore() {
        var qsScore = Float(queLevel2.score) / Float(queLevel2.correctAnswers?.count ?? 1)
        if queLevel2.correctAnswers?.count == 1 {
            qsScore = Float(queLevel2.score)
        }
        
        var total = 0.0
        var correct = 0
        for (index, userAnswer) in queLevel2.userAnswers.enumerated() {
            let correctAnswers = queLevel2.correctAnswers?[index]
            if let correctAnswer = correctAnswers?.components(separatedBy: "/") {
                if correctAnswer.count > 1 {
                    for answer in correctAnswer {
                        if answer.removeSpace() == userAnswer.removeSpace() {
                            total += Double(qsScore)
                            correct += 1
                            break
                        }
                    }
                } else {
                    if correctAnswers?.removeSpace() == userAnswer.removeSpace(){
                        total += Double(qsScore)
                        correct += 1
                    }
                }
            }
        }
        if correct == queLevel2.userAnswers.count {
            total = queLevel2.score
        }
        queLevel2.userScore = total
        print("\(NSStringFromClass(Self.self)) \(#function) score:\(total)")
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
