//
//  QueContentDescribeModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit

class QueContentDescribeModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentDescribeCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let attr: NSAttributedString
    
    init?(html: String) {
        guard let data = html.data(using: .utf8) else {
            return nil
        }
        let hpple = TFHpple(data: data, isXML: false)
        if let elements = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement] {
            var text = ""
            for element in elements {
                // 去掉<p></p>
                if let raw = element.raw {
                    let content = (element.raw as NSString).substring(with: .init(location: 3, length: raw.count - 3 - 4))
                    text += content + "\n"
                }
            }
            
            let attr = text.handleUIB(fontSize: 16)
            
            self.attr = attr
        } else {
            let attr = html.handleUIB(fontSize: 16)
            
            self.attr = attr
        }
    }
    
    convenience init?(queLevel2: QueLevel2) {
        guard let content = queLevel2.content else {
            return nil
        }
        self.init(html: content)
    }
}
