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
    
    init?(queLevel2: QueLevel2) {
        guard let content = queLevel2.content, content.contains("<img") else {
            return nil
        }
        let data = content.data(using: .utf8)
        let hpple = TFHpple(htmlData: data)
        
        if let element = (hpple?.search(withXPathQuery: "//img") as? [TFHppleElement])?.first {
            if let src = element.object(forKey: "src") {
                var imageURL : URL!
                let model = ImgModel(src: src)
                if let width = element.object(forKey: "width") {
                    model.width = CGFloat(Float(width)!)
                }
                if let height = element.object(forKey: "height") {
                    model.height = CGFloat(Float(height)!)
                }
                print("\(NSStringFromClass(Self.self)) \(#function) url: \(model.src) width: \(String(describing: model.width)) height: \(String(describing: model.height))")
                self.imageModel = model
            } else {
                return nil
            }
        } else {
            return nil
        }
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
    }
}
