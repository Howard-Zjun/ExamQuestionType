//
//  QueContentFillBlankModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/13.
//

import UIKit

let snFillBlankURLPrefix = "blank"

let snSeparate = ":"

class QueContentFillBlankModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentFillBlankCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let queLevel2: QueLevel2
    
    var fillBlankAttrStrArr: [NSMutableAttributedString]
    
    var allAttrStrArr: [NSMutableAttributedString]
    
    var resultAttributed: NSMutableAttributedString
    
    var focunsIndex: Int? {
        didSet {
            if let focunsIndex = oldValue, focunsIndex < fillBlankAttrStrArr.count {
                if getAnswer(index: focunsIndex) == nil {
                    let newFillBlankStr = emptyFillBlankAttrStr(index: focunsIndex)
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
                fillBlankAttrStrArr[focunsIndex].addAttribute(.underlineColor, value: UIColor(hex: "2F81FB"), range: .init(location: 0, length: fillBlankAttrStrArr[focunsIndex].length))
            }
            makeResultAttr()
        }
    }
    
    init?(queLevel2: QueLevel2) {
        guard queLevel2.type == .FillBlank else {
            return nil
        }
        self.queLevel2 = queLevel2
        let originContent1 = "\(queLevel2.no)" + HTMLTranslate.stripBlk(html: queLevel2.content ?? "") // <blk> 转 ___
        
        self.allAttrStrArr = []
        self.fillBlankAttrStrArr = []
        self.resultAttributed = NSMutableAttributedString()
        super.init()
        
        let comStrArr = originContent.components(separatedBy: "___")
        for (index, itemStr) in comStrArr.enumerated() {
            if !allAttrStrArr.isEmpty {
                let fillBlankIndex = index - 1
                var enterStr = spaceStr
                var haveAnswer = false
                if let count = queLevel2.userAnswers.count, fillBlankIndex < count, let answer = queLevel2.userAnswers[fillBlankIndex], !answer.isEmpty {
                    enterStr = answer
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
                    fillBlankAttrStr = emptyFillBlankAttrStr(index: fillBlankIndex)
                }
                fillBlankAttrStrArr.append(fillBlankAttrStr)
                allAttrStrArr.append(fillBlankAttrStr)
            }
            allAttrStrArr.append(.init(string: itemStr, attributes: [
                .font : UIFont.systemFont(ofSize: 18),
                .foregroundColor : UIColor.black,
            ]))
        }
        for itemAttrStr in allAttrStrArr {
            resultAttributed.append(itemAttrStr)
        }
        resultAttributed.addAttribute(.baselineOffset, value: NSNumber(value: 5), range: .init(location: 0, length: resultAttributed.length))
    }
    
    func setAnswer(text: String) {
        updateAttributed(text: text)
        updateStoreData(text: text)
    }
    
    func getAnswer(index: Int) -> String? {
        while let count1 = qst.userAnswers.count, let count2 = qst.correctAnswers.count, count1 < count2 {
            qst.userAnswers.append("")
        }
        if let ret = qst.userAnswers[index], !ret.isEmpty {
            return ret
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
            newFillBlank = emptyFillBlankAttrStr(index: index)
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
        while let count1 = qst.userAnswers.count, let count2 = qst.correctAnswers.count, count1 < count2 {
            qst.userAnswers.append("")
        }
        print("\(NSStringFromClass(Self.self)) \(#function) text: \(text)")
        qst.userAnswers[index] = text
    }
    
    func updateScore() {
        var qsScore = Float(queLevel2.score) / Float(queLevel2.correctAnswers.count)
        if queLevel2.correctAnswers.count == 1 {
            qsScore = Float(queLevel2.score)
        }
        
        var total = 0.0
        var correct = 0
        for (index, userAnswer) in queLevel2.userAnswers.enumerated() {
            let correctAnswers = queLevel2.correctAnswers[index]
            if let correctAnswer = correctAnswers.components(separatedBy: "/") {
                if correctAnswer.count > 1 {
                    for answer in correctAnswer {
                        if answer.removeSpace() == userAnswer.removeSpace() {
                            total += Double(qsScore)
                            correct += 1
                            break
                        }
                    }
                } else {
                    if correctAnswers.removeSpace() == userAnswer.removeSpace(){
                        total += Double(qsScore)
                        correct += 1
                    }
                }
            }
        }
        if correct == queLevel2.userAnswers.count {
            total = score
        }
        queLevel2.userScore = total
        print("\(NSStringFromClass(Self.self)) \(#function) score:\(total)")
    }
    
    func emptyFillBlankAttrStr(index: Int) -> NSMutableAttributedString {
        // 只能逐个添加，使用 addAttribute 添加附件没有效果
        let ret = NSMutableAttributedString()
        ret.append(.init(string: "⌘"))
        
        if isFocus {
            ret.append(.init(string: "⌘"))
        } else {
            let attachment = NSTextAttachment(image: .init(named: "blank_icon_edit")!)
            attachment.bounds = .init(x: 0, y: 0, width: 18, height: 18)
            ret.append(.init(attachment: attachment))
        }
        
        ret.append(.init(string: "⌘"))
        
        ret.addAttributes([
            .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
            .underlineColor : isFocus ? UIColor(hex: "2F81FB") : UIColor.black,
            .link : "\(fillBlankURLPrefix)\(index)",
            .font : UIFont.systemFont(ofSize: 18),
            .foregroundColor : UIColor.clear,
        ], range: .init(location: 0, length: ret.length))
        return ret
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
