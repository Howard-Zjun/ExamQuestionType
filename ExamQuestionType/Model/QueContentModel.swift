//
//  QueContentModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit

protocol QueContentModelDelegate {
        
    func contentDidChange(model: QueContentModel)
}

protocol QueContentModel {

    var cellType: UITableViewCell.Type { get }
    
    var contentInset: UIEdgeInsets { set get } 
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
    
    static func normalResolver(queLevel2: QueLevel2, isResult: Bool = false) -> [QueContentModel] {
        let no = queLevel2.no ?? ""
        let content = queLevel2.content ?? ""
        let html = no + content
        guard !html.isEmpty else {
            return []
        }
        
        let tempModels = normalResolver(html: html, isResult: isResult)
        
        return fixDescribe(contentModels: tempModels)
    }
    
    static func normalResolver(html: String, isResult: Bool) -> [QueContentModel] {
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

                let tempRet = normalResolver(html: content, isResult: isResult)
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
                if let tableModel = QueContentTableModel(html: tempStr) {
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

    
    static func essayResolver(queLevel2: QueLevel2, isResult: Bool = false) -> [QueContentModel] {
        let no = queLevel2.no ?? ""
        let content = queLevel2.content ?? ""
        let html = no + content
        guard !html.isEmpty else {
            return []
        }
        
        let tempModels = essayResolver(queLevel2: queLevel2, html: html, essayOffset: 0, isResult: isResult)
        
        return fixDescribe(contentModels: tempModels)
    }
    
    static func essayResolver(queLevel2: QueLevel2, html: String, essayOffset: Int, isResult: Bool) -> [QueContentModel] {
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
                let tempRet = essayResolver(queLevel2: queLevel2, html: content, essayOffset: essayOffset + essayIndex, isResult: isResult)
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
                if let tableModel = QueContentTableModel(html: tempStr) {
                    ret.append(tableModel)
                }
            } else if tempStr.hasPrefix("<img") {
                if let imgModel = QueContentImgModel(html: tempStr) {
                    ret.append(imgModel)
                }
            } else if tempStr.hasPrefix("<blk") {
                if let essayModel = QueContentEssayModel(queLevel2: queLevel2, index: essayOffset  + essayIndex, isResult: isResult) {
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

    
    static func fillBlankResolver(queLevel2: QueLevel2, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        if let fillBlankModel = QueContentFillBlankModel(queLevel2: queLevel2, isResult: isResult) {
            retModels.append(fillBlankModel)
        }
        
        return retModels
    }
    
    static func selectFillBlankResolver(queLevel2: QueLevel2, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        if let selectFillBlankModel = QueContentSelectFillBlankModel(queLevel2: queLevel2, isResult: isResult) {
            retModels.append(selectFillBlankModel)
        }
        return retModels
    }
    
    static func selectResolver(queLevel2: QueLevel2, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        if let selectModel = QueContentSelectContentModel(queLevel2: queLevel2, isResult: isResult) {
            retModels.append(selectModel)
        }
        
        return retModels
    }
    
    static func conversationResolver(queLevel2: QueLevel2, isResult: Bool = false) -> [QueContentModel] {
        let retModels = normalResolver(queLevel2: queLevel2, isResult: isResult)
        
        return retModels
    }
}
