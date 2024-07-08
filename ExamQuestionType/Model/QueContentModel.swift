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
    
    static func essayResolver(queLevel2: QueLevel2) -> [QueContentModel] {
        guard queLevel2.type == .essay, let html = queLevel2.content else {
            return []
        }
        
        let tempRet = essayResolver(queLevel2: queLevel2, html: html, essayOffset: 0)
        
        var ret: [QueContentModel] = []
        var right = 0
        var contentAttr = NSMutableAttributedString()
        while right < tempRet.count {
            if let describeModel = tempRet[right] as? QueContentDescribeModel {
                contentAttr.append(describeModel.attr)
            } else {
                if !contentAttr.string.isEmpty {
                    while contentAttr.string.hasSuffix("\n") {
                        contentAttr.replaceCharacters(in: .init(location: contentAttr.length - 1, length: 1), with: "")
                    }
                    if !contentAttr.string.isEmpty {
                        ret.append(QueContentDescribeModel(attr: contentAttr))
                    }
                    
                    contentAttr = .init()
                }
                retModels.append(tempModels[right])
            }
            right += 1
        }
        if !contentAttr.string.isEmpty {
            while contentAttr.string.hasSuffix("\n") {
                contentAttr.replaceCharacters(in: .init(location: contentAttr.length - 1, length: 1), with: "")
            }
            if !contentAttr.string.isEmpty {
                ret.append(QueContentDescribeModel(attr: contentAttr))
            }
        }
        
        return ret
    }
    
    static func essayResolver(queLevel2: QueLevel2, html: String, essayOffset: Int) -> [QueContentModel] {
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
                let content = (tempStr as NSString).substring(with: .init(location: 3, length: tempStr.count - 3 - 4)) // 去掉<p></p>

                let tempRet = essayResolver(queLevel2: queLevel2, html: content, essayOffset: essayOffset + essayIndex)
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
                if let essayModel = QueContentEssayModel(queLevel2: queLevel2, index: essayOffset  + essayIndex) {
                    ret.append(essayModel)
                    
                    essayIndex += 1
                }
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 后面有未识别的内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))

            if let describeModel = QueContentDescribeModel(html: noHandleStr) {
                ret.append(describeModel)
            }
        }
        return ret
    }
    
    static func fillBlankResolver(queLevel2: QueLevel2) -> [QueContentModel] {
        guard queLevel2.type == .FillBlank else {
            return []
        }
        
        if let fillBlankModel = QueContentFillBlankModel(queLevel2: queLevel2) {
            return [fillBlankModel]
        } else {
            return []
        }
    }
    
    static func selectResolver(queLevel2: QueLevel2) -> [QueContentModel] {
        guard queLevel2.type == .Select else {
            return []
        }
        
        if let selectModel = QueContentSelectModel(queLevel2: queLevel2) {
            return [selectModel]
        } else if let selectModel = QueContentFillBlankModel(queLevel2: queLevel2) {
            return [selectModel]
        } else {
            return []
        }
    }
    
    static func contentResolver(queLevel1: QueLevel1, queLevel2: QueLevel2) -> [QueContentModel] {
        var tempModels: [QueContentModel] = []
        var queue: [QueLevel2] = [queLevel2]
        var index = 0
        
        let titleModel = QueContentTitleModel(queLevel1: queLevel1)
        tempModels.append(titleModel)
        
        while index < queue.count {
            let model = queue[index]
                
            if model.type == .essay {
                tempModels += essayResolver(queLevel2: model)
            } else if model.type == .FillBlank {
                tempModels += fillBlankResolver(queLevel2: model)
            } else if model.type == .Select {
                tempModels += selectResolver(queLevel2: model)
            } else {
                guard let data = model.content?.data(using: .utf8) else {
                    continue
                }
                let hpple = TFHpple(data: data, isXML: false)
                guard let elements = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement] else {
                    continue
                }
                
                for (elementIndex, element) in elements.enumerated() {
                    for item in (element.children as? [TFHppleElement]) ?? [] {
                        if item.tagName == "text" {
                            if let describeModel = QueContentDescribeModel(html: item.content + "\n") {
                                tempModels.append(describeModel)
                            }
                        } else if item.tagName == "img" {
                            if let imgModel = QueContentImgModel(html: item.raw) {
                                tempModels.append(imgModel)
                            }
                        } else if item.tagName == "table" {
                            if let tableModel = QueContentTableModel(html: item.raw) {
                                tempModels.append(tableModel)
                            }
                        }
                    }
                }
            }
            
            if let subLevel2 = model.subLevel2 {
                queue += subLevel2
            }
            
            index += 1
        }
        
        var right = 0
        var retModels: [QueContentModel] = []
        var attr = NSMutableAttributedString()
        // 将 QueContentDescribeModel 整合
        while right < tempModels.count {
            if let describeModel = tempModels[right] as? QueContentDescribeModel {
                attr.append(describeModel.attr)
            } else {
                if !attr.string.isEmpty {
                    while attr.string.hasSuffix("\n") {
                        attr.replaceCharacters(in: .init(location: attr.length - 1, length: 1), with: "") // 去掉\n
                    }
                    let describeModel = QueContentDescribeModel(attr: attr)
                    retModels.append(describeModel)
                    
                    attr = .init()
                }
                retModels.append(tempModels[right])
            }
            right += 1
        }
        
        if !attr.string.isEmpty {
            while attr.string.hasSuffix("\n") {
                attr.replaceCharacters(in: .init(location: attr.length - 1, length: 1), with: "") // 去掉\n
            }
            let describeModel = QueContentDescribeModel(attr: attr)
            retModels.append(describeModel)
        }
        return retModels
    }
}
