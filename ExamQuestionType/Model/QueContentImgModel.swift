//
//  QueContentImgModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit

class QueContentImgModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentImgCell.self
    }
    
    var contentInset: UIEdgeInsets = .init(top: 0, left: 18, bottom: 0, right: 18)
    
    var estimatedHeight: CGFloat?

    let imageModel: ImgModel
    
    init(model: ImgModel) {
        self.imageModel = model
    }
    
    convenience init?(html: String) {
        guard let model = ImgModel.load(html: html)?.first else {
            return nil
        }
        self.init(model: model)
    }
    
    convenience init?(question: QuestionNode) {
        guard let content = question.content else {
            return nil
        }
        self.init(html: content)
    }
}

extension QueContentImgModel {
    
    class ImgModel {
        
        var text :String?
        
        let src :URL
        
        var width: CGFloat?
        
        var height: CGFloat?
        
        init(text: String? = nil, src: URL, width: CGFloat? = nil, height: CGFloat? = nil) {
            self.text = text
            self.src = src
            self.width = width
            self.height = height
        }
        
        static func load(html: String) -> [ImgModel]? {
            guard let document = try? HTMLDocument(html: html), let root = document.body ?? document.root else {
                return nil
            }
            var ret: [ImgModel] = []
            for node in root.allMatchNode(tagName: "img") {
                if let src = node.attribute(named: "src"), let url = URL(string: src) {
                    let model = ImgModel(src: url)
                    if let width = node.attribute(named: "width") {
                        model.width = CGFloat(Float(width)!)
                    }
                    if let height = node.attribute(named: "height") {
                        model.height = CGFloat(Float(height)!)
                    }
                    print("\(NSStringFromClass(Self.self)) \(#function) url: \(model.src) width: \(String(describing: model.width)) height: \(String(describing: model.height))")
                    ret.append(model)
                }
            }
            
            if ret.isEmpty {
                return []
            } else {
                return ret
            }
        }
    }
}
