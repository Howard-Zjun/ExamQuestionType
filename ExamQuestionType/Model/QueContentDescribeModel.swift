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
    
    let handleContentAttr: NSMutableAttributedString
    
    init(attr: NSAttributedString) {
        self.handleContentAttr = attr
    }
    
    convenience init?(html: String, fontSize: CGFloat = 18, baselineOffset: Int = 5, needStyle: Bool = true) {
        guard let data = html.data(using: .utf8) else {
            return nil
        }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.paragraphSpacing = 5
                
        let hpple = TFHpple(data: data, isXML: false)
        if let elements = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement], !elements.isEmpty {
            let handleContentAttr = NSMutableAttributedString()
            
            for (elementIndex, element) in elements.enumerated() {
                var pStyle: NSMutableParagraphStyle = style
                if let align = element.attributes["align"] as? String {
                    pStyle = .init()
                    pStyle.lineSpacing = 5
                    pStyle.paragraphSpacing = 5
                    if align.lowercased() == "right" {
                        pStyle.alignment = .right
                    } else if align.lowercased() == "left" {
                        pStyle.alignment = .right
                    }
                }
                // 去掉<p></p>
                if let raw = element.raw {
                    let firstPEnd = (element.raw as NSString).range(of: ">").location + 1
                    let content = (element.raw as NSString).substring(with: .init(location: firstPEnd, length: raw.count - firstPEnd - 4))
                    let tempAttr = NSMutableAttributedString(string: content)
                    if needStyle {
                        tempAttr.addAttribute(.paragraphStyle, value: pStyle, range: .init(location: 0, length: tempAttr.length))
                    }
                    handleContentAttr.append(tempAttr)
                    
                    if elementIndex < elements.count - 1 {
                        handleContentAttr.append(.init(string: "\n"))
                    }
                }
            }
            handleContentAttr.handle(type: [.uTag, .iTag, .bTag, .blk, .br], fontSize: fontSize, baselineOffset: baselineOffset)
            self.handleContentAttr = handleContentAttr
        } else {
            self.handleContentAttr = html.handle(type: [.uTag, .iTag, .bTag, .blk, .br], fontSize: fontSize, paragraphStyle: needStyle ? style : nil, baselineOffset: baselineOffset)
        }
    }
    
    func set(textAlignment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 5
        paragraphStyle.alignment = textAlignment
        handleContentAttr.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: handleContentAttr.length))
        
    }
}
