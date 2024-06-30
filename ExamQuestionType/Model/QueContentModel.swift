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
    
    static func essayResolver(queLevel2: QueLevel2) -> [QueContentModel] {
        guard queLevel2.type == .essay, let data = queLevel2.content?.data(using: .utf8) else {
            return []
        }
        let hpple = TFHpple(data: data, isXML: false)
        guard let elements = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement] else {
            return []
        }
        var ret: [QueContentModel] = []
        
        var essayIndex = 0
        for element in elements {
            for item in (element.children as? [TFHppleElement]) ?? [] {
                if item.tagName == "text" {
                    if let describeModel = QueContentDescribeModel(html: item.content) {
                        ret.append(describeModel)
                    }
                } else if item.tagName == "img" {
                    if let imgModel = QueContentImgModel(html: item.raw) {
                        ret.append(imgModel)
                    }
                } else if item.tagName == "table" {
                    if let tableModel = QueContentTableModel(html: item.raw) {
                        ret.append(tableModel)
                    }
                } else if item.tagName == "blk" {
                    if let essayModel = QueContentEssayModel(queLevel2: queLevel2, index: essayIndex) {
                        ret.append(essayModel)
                        
                        essayIndex += 1
                    }
                }
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
        var ret: [QueContentModel] = []
        var queue: [QueLevel2] = [queLevel2]
        var index = 0
        
        let titleModel = QueContentTitleModel(queLevel1: queLevel1)
        ret.append(titleModel)
        
        while index < queue.count {
            let model = queue[index]
                
            if model.type == .essay {
                ret += essayResolver(queLevel2: model)
            } else if model.type == .FillBlank {
                ret += fillBlankResolver(queLevel2: model)
            } else if model.type == .Select {
                ret += selectResolver(queLevel2: model)
            } else {
                guard let data = model.content?.data(using: .utf8) else {
                    return ret
                }
                let hpple = TFHpple(data: data, isXML: false)
                guard let elements = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement] else {
                    return ret
                }
                
                for element in elements {
                    for item in (element.children as? [TFHppleElement]) ?? [] {
                        if item.tagName == "text" {
                            if let describeModel = QueContentDescribeModel(html: item.content) {
                                ret.append(describeModel)
                            }
                        } else if item.tagName == "img" {
                            if let imgModel = QueContentImgModel(html: item.raw) {
                                ret.append(imgModel)
                            }
                        } else if item.tagName == "table" {
                            if let tableModel = QueContentTableModel(html: item.raw) {
                                ret.append(tableModel)
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
        
        return ret
    }
}
