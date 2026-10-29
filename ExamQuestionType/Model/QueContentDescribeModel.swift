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
    
    var contentInset: UIEdgeInsets = .init(top: 0, left: 18, bottom: 0, right: 18)
    
    var estimatedHeight: CGFloat?
    
    var estimateContentHeight: CGFloat {
        _handleContentAttr.textHeight(textWidth: kScreenWidth - contentInset.left - contentInset.right, withFont: font)
    }
    
    var font: UIFont {
        .systemFont(ofSize: 17)
    }
    
    var handleContentAttr: NSAttributedString {
        _handleContentAttr
    }
    
    private let _handleContentAttr: NSMutableAttributedString
    
    init(attr: NSMutableAttributedString) {
        self._handleContentAttr = attr
    }
    
    convenience init?(html: String, fontSize: CGFloat = 18, baselineOffset: Int = 5, needStyle: Bool = true) {
        guard let document = try? HTMLDocument(html: html),
              let root = document.body ?? document.root else {
            return nil
        }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.paragraphSpacing = 5
                
        let elements = root.allMatchNode(tagName: "p")
        if !elements.isEmpty {
            let handleContentAttr = NSMutableAttributedString()
            
            for (elementIndex, element) in elements.enumerated() {
                var pStyle: NSMutableParagraphStyle = style
                if let align = element.attribute(named: "align") {
                    pStyle = .init()
                    pStyle.lineSpacing = 5
                    pStyle.paragraphSpacing = 5
                    if align.lowercased() == "right" {
                        pStyle.alignment = .right
                    } else if align.lowercased() == "left" {
                        pStyle.alignment = .left
                    } else if align.lowercased() == "center" {
                        pStyle.alignment = .center
                    }
                }
                // 按原顺序序列化段落的子节点，保留内联标签供后续富文本转换。
                let content = element.children.compactMap { $0.outerHTML }.joined()
                let tempAttr = NSMutableAttributedString(string: content)
                if needStyle {
                    tempAttr.addAttribute(.paragraphStyle, value: pStyle, range: .init(location: 0, length: tempAttr.length))
                }
                handleContentAttr.append(tempAttr)

                if elementIndex < elements.count - 1 {
                    handleContentAttr.append(.init(string: "\n"))
                }
            }
            handleContentAttr.handle(fontSize: fontSize, baselineOffset: baselineOffset)
            self.init(attr: handleContentAttr)
        } else {
            let attr = html.handle(fontSize: fontSize, paragraphStyle: needStyle ? style : nil, baselineOffset: baselineOffset)
            self.init(attr: attr)
        }
    }
    
    func set(textAlignment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 5
        paragraphStyle.alignment = textAlignment
        _handleContentAttr.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: handleContentAttr.length))
        
    }
}
