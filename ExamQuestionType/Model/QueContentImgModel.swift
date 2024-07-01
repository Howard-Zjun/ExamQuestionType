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
    
    var contentInset: UIEdgeInsets = .zero
    
    let imageModel: ImgModel
    
    init?(html: String) {
        guard let model = ImgModel.load(html: html)?.first else {
            return nil
        }
        self.imageModel = model
    }
    
    convenience init?(queLevel2: QueLevel2) {
        guard let content = queLevel2.content else {
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
            guard let data = html.data(using: .utf8) else {
                return nil
            }
            let hpple = TFHpple(data: data, isXML: false)
            guard let elements = hpple?.search(withXPathQuery: "//img") as? [TFHppleElement] else {
                return nil
            }
            
            var ret: [ImgModel] = []
            for element in elements {
                if let src = element.object(forKey: "src"), let url = URL(string: src) {
                    let model = ImgModel(src: url)
                    if let width = element.object(forKey: "width") {
                        model.width = CGFloat(Float(width)!)
                    }
                    if let height = element.object(forKey: "height") {
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
