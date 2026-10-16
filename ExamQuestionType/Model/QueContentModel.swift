//
//  QueContentModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit

protocol QueContentModelDelegate: NSObjectProtocol {
        
    func contentDidChange(model: QueContentModel)
}

protocol QueContentModel {

    var cellType: UITableViewCell.Type { get }
    
    var contentInset: UIEdgeInsets { set get } 
    
    var estimatedHeight: CGFloat? { get set }
}

class QueContentResolver {
    
    /// 将 QueContentDescribeModel 整合
    static func fixDescribe(contentModels: [QueContentModel]) -> [QueContentModel] {
        var right = 0
        var retModels: [QueContentModel] = []
        var contentAttr = NSMutableAttributedString()
        
        func finishDescribe() {
            if !contentAttr.string.isEmpty {
                while contentAttr.string.hasPrefix("\n") {
                    contentAttr.replaceCharacters(in: .init(location: 0, length: 1), with: "")
                }
                while contentAttr.string.hasSuffix("\n") {
                    contentAttr.replaceCharacters(in: .init(location: contentAttr.length - 1, length: 1), with: "")
                }
                if !contentAttr.string.isEmpty {
                    let describeModel = QueContentDescribeModel(attr: contentAttr)
                    retModels.append(describeModel)
                }
                
                contentAttr = .init()
            }
        }
        
        while right < contentModels.count {
            if let describeModel = contentModels[right] as? QueContentDescribeModel {
                contentAttr.append(describeModel.handleContentAttr)
            } else {
                finishDescribe()
                retModels.append(contentModels[right])
            }
            right += 1
        }
        finishDescribe()
        
        return retModels
    }
    
    static func normalResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        let no = Tool.noHandle(no: question.no)
        let content = question.content ?? ""
        let html = no + content
        guard !html.isEmpty else {
            return []
        }
        
        let tempModels = normalResolver(question: question, html: html, isResult: isResult)
        
        return fixDescribe(contentModels: tempModels)
    }
    
    static func normalResolver(question: QuestionNode, html: String, isResult: Bool) -> [QueContentModel] {
        var ret: [QueContentModel] = []
        let pRegex = try! NSRegularExpression(pattern: "(<table.*?</table>)|(<img.*?>)|(<blk.*?</blk>)|(<p.*?</p>)")

        var lastIndex = 0
        
        pRegex.enumerateMatches(in: html, range: .init(location: 0, length: html.count)) { match, _, _ in
            guard let range = match?.range else { return }
            
            if range.location != lastIndex { // 有未识别内容
                let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: range.location - lastIndex))
                
                if let describeModel = QueContentDescribeModel(html: noHandleStr) {
                    ret.append(describeModel)
                }
            }
            
            let tempStr = (html as NSString).substring(with: range)
            
            if tempStr.hasPrefix("<p") {
                let firstPEnd = (tempStr as NSString).range(of: ">").location + 1
                let content = (tempStr as NSString).substring(with: .init(location: firstPEnd, length: tempStr.count - firstPEnd - 4)) // 去掉<p></p>

                let tempRet = normalResolver(question: question, html: content, isResult: isResult)
                // 处理对齐
                if let aligment = tempStr.resolverPAligment() {
                    for temp in tempRet {
                        if let describeModel = temp as? QueContentDescribeModel {
                            describeModel.set(textAlignment: aligment)
                        }
                    }
                }
                ret += tempRet
                if let describeModel = QueContentDescribeModel(html: "\n") {
                    ret.append(describeModel)
                }
            } else if tempStr.hasPrefix("<table") {
                if let tableModel = QueContentTableModel(question: question, html: tempStr, isResult: isResult) {
                    ret.append(tableModel)
                }
            } else if tempStr.hasPrefix("<img") {
                if let imgModel = QueContentImgModel(html: tempStr) {
                    ret.append(imgModel)
                }
            } else if tempStr.hasPrefix("<blk") {
                if let describeModel = QueContentDescribeModel(html: "____") {
                    ret.append(describeModel)
                }
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 有未识别内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))

            if let describeModel = QueContentDescribeModel(html: noHandleStr) {
                ret.append(describeModel)
            }
        }
        
        return ret
    }

    
    static func essayResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        let no = Tool.noHandle(no: question.no)
        let content = question.content ?? ""
        let html = no + content
        guard !html.isEmpty else {
            return []
        }
        
        let tempModels = essayResolver(question: question, html: html, essayOffset: 0, isResult: isResult)
        
        return fixDescribe(contentModels: tempModels)
    }
    
    static func essayResolver(question: QuestionNode, html: String, essayOffset: Int, isResult: Bool) -> [QueContentModel] {
        var ret: [QueContentModel] = []
        let pRegex = try! NSRegularExpression(pattern: "(<table.*?</table>)|(<img.*?>)|(<blk.*?</blk>)|(<p.*?</p>)")

        var lastIndex = 0
        
        var essayIndex = 0
        
        pRegex.enumerateMatches(in: html, range: .init(location: 0, length: html.count)) { match, _, _ in
            guard let range = match?.range else { return }
            
            if range.location != lastIndex { // 有未识别内容
                let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: range.location - lastIndex))
                
                if let describeModel = QueContentDescribeModel(html: noHandleStr) {
                    ret.append(describeModel)
                }
            }
            
            let tempStr = (html as NSString).substring(with: range)
            
            if tempStr.hasPrefix("<p") {
                let firstPEnd = (tempStr as NSString).range(of: ">").location + 1
                let content = (tempStr as NSString).substring(with: .init(location: firstPEnd, length: tempStr.count - firstPEnd - 4)) // 去掉<p></p>
                let tempRet = essayResolver(question: question, html: content, essayOffset: essayOffset + essayIndex, isResult: isResult)
                if let aligment = tempStr.resolverPAligment() {
                    for temp in tempRet {
                        if let describeModel = temp as? QueContentDescribeModel {
                            describeModel.set(textAlignment: aligment)
                        }
                    }
                }
                ret += tempRet
                if let describeModel = QueContentDescribeModel(html: "\n") {
                    ret.append(describeModel)
                }
            } else if tempStr.hasPrefix("<table") {
                if let tableModel = QueContentTableModel(question: question, html: tempStr, isResult: isResult) {
                    ret.append(tableModel)
                }
            } else if tempStr.hasPrefix("<img") {
                if let imgModel = QueContentImgModel(html: tempStr) {
                    ret.append(imgModel)
                }
            } else if tempStr.hasPrefix("<blk") {
                if let essayModel = QueContentEssayModel(question: question, index: essayOffset  + essayIndex, isResult: isResult) {
                    ret.append(essayModel)
                    
                    essayIndex += 1
                }
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 有未识别内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))

            if let describeModel = QueContentDescribeModel(html: noHandleStr) {
                ret.append(describeModel)
            }
        }
        
        return ret
    }

    
    static func fillBlankResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        if let tableFillBlankModel = QueContentTableModel(question: question, isResult: isResult) {
            retModels.append(tableFillBlankModel)
        } else if let fillBlankModel = QueContentFillBlankModel(question: question, isResult: isResult) {
            retModels.append(fillBlankModel)
        }
        
        return retModels
    }
    
    static func selectFillBlankResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        if let selectFillBlankModel = QueContentSelectFillBlankModel(question: question, isResult: isResult) {
            retModels.append(selectFillBlankModel)
        }
        return retModels
    }
    
    static func selectResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        retModels += normalResolver(question: question, isResult: isResult)
        if let selectOptionModel = QueContentSelectOptionModel(question: question, isResult: isResult) {
            retModels.append(selectOptionModel)
        }
        
        return retModels
    }
    
    static func conversationResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        let retModels = normalResolver(question: question, isResult: isResult)
        
        return retModels
    }
}
