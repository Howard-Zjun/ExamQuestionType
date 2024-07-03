//
//  Extension.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/23.
//

import UIKit

extension UIView {
    
    var kminX: CGFloat {
        frame.minX
    }
    
    var kminY: CGFloat {
        frame.minY
    }
    
    var kmaxX: CGFloat {
        frame.maxX
    }
    
    var kmaxY: CGFloat {
        frame.maxY
    }
    
    var kwidth: CGFloat {
        frame.width
    }
    
    var kheight: CGFloat {
        frame.height
    }
}

extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int, a: Int = 1) {
        assert(r > 0 && r < 256, "Invalid red component")
        assert(g >= 0 && g <= 255, "Invalid green component")
        assert(b >= 0 && b <= 255, "Invalid blue component")
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
    
    convenience init(hex: Int) {
        let r = (hex >> 16) & 0xff
        let g = (hex >> 8) & 0xff
        let b = hex & 0xff
        self.init(r: r, g: g, b: b)
    }
}

extension NSAttributedString {
    
    static func emptyFillBlankAttrStr(index: Int, isFocus: Bool = false, paragraphStyle: NSParagraphStyle = .default) -> NSMutableAttributedString {
        // 只能逐个添加，使用 addAttribute 添加附件没有效果
        let ret = NSMutableAttributedString()
        ret.append(.init(string: "⌘"))
        
        if isFocus {
            ret.append(.init(string: "⌘"))
        } else {
            let attachment = NSTextAttachment(image: .init(named: "blank_icon_edit")!)
            attachment.bounds = .init(x: 0, y: 0, width: 18, height: 18)
            ret.append(.init(attachment: attachment))
        }
        
        ret.append(.init(string: "⌘"))
        
        ret.addAttributes([
            .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
            .underlineColor : isFocus ? UIColor(hex: 0x2F81FB) : UIColor.black,
            .link : "\(snFillBlankURLPrefix)\(snSeparate)\(index)",
            .font : UIFont.systemFont(ofSize: 18),
            .foregroundColor : UIColor.clear,
            .paragraphStyle : paragraphStyle,
        ], range: .init(location: 0, length: ret.length))
        return ret
    }
}

extension String {
    
    func removeSpace() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func stripBlk() -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        
        var ret = ""
        
        let hpple = TFHpple(data: data, isXML: false)
        let elements = hpple?.search(withXPathQuery: "//p") as! [TFHppleElement]
        
        for element in elements {
            for item in (element.children as? [TFHppleElement]) ?? [] {
                if item.raw == "blk" {
                    ret += "___"
                } else if item.raw == "text" {
                    ret += element.content
                }
            }
            ret += "\n"
        }
        return ret
    }
    
    /// 下划线、斜体、加粗样式
    func handleUIB(fontSize: CGFloat, foregroundColor: UIColor = .black, paragraphStyle: NSParagraphStyle = .default, baselineOffset: Int = 0) -> NSMutableAttributedString {
        let regex = try! NSRegularExpression(pattern: "(<u>.*?</u>)|(<i>.*?</i>)|(<b>.*?</b>)")

        var locationOffset = 0

        let attr = NSMutableAttributedString(string: self, attributes: [
            .font : UIFont.systemFont(ofSize: fontSize),
        ])
        
        regex.enumerateMatches(in: self, options: [], range: .init(location: 0, length: self.count)) { match, _, _ in
            if let range = match?.range {
                let originContent = (self as NSString).substring(with: range)
                let content = (originContent as NSString).substring(with: .init(location: 3, length: originContent.count - 3 - 4)) // 去掉前后标签
                
                attr.replaceCharacters(in: .init(location: locationOffset + range.location, length: range.length), with: content)

                if originContent.hasPrefix("<u>") {
                    attr.addAttributes([
                        .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                        .underlineColor : UIColor.black,
                    ], range: .init(location: locationOffset + range.location, length: content.count))
                } else if originContent.hasPrefix("<i>") {
                    attr.addAttributes([
                        .obliqueness : NSNumber(value: 0.5),
                    ], range: .init(location: locationOffset + range.location, length: content.count))
                } else if originContent.hasPrefix("<b>") {
                    attr.addAttributes([
                        .font : UIFont.systemFont(ofSize: fontSize, weight: .bold),
                    ], range: .init(location: locationOffset + range.location, length: content.count))
                }
                
                locationOffset = locationOffset + (content.count - originContent.count)
            }
        }
        
        attr.addAttributes([
            .foregroundColor : foregroundColor,
            .baselineOffset : NSNumber(value: baselineOffset)
        ], range: .init(location: 0, length: attr.length))

        return attr
    }
    
    func fillBlankAttr(font: UIFont, link: String, foregroundColor: UIColor = .black,paragraphStyle: NSParagraphStyle = .default) -> NSMutableAttributedString {
        let ret = NSMutableAttributedString()
        ret.append(.init(string: "⌘", attributes: [
            .foregroundColor : UIColor.clear
        ]))
        
        ret.append(.init(string: self, attributes: [
            .foregroundColor : foregroundColor
        ]))
        
        ret.append(.init(string: "⌘", attributes: [
            .foregroundColor : UIColor.clear
        ]))
        
        ret.addAttributes([
            .font : font,
            .link : link,
            .underlineColor : UIColor.black,
            .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
            .paragraphStyle : paragraphStyle
        ], range: .init(location: 0, length: ret.length))
        return ret
    }
}

extension UITableView {
    
    func register<T : UITableViewCell>(_ cellType: T.Type) {
        if Bundle.main.path(forResource: String(describing: cellType), ofType: "nib")?.first != nil {
            register(.init(nibName: String(describing: cellType), bundle: nil), forCellReuseIdentifier: NSStringFromClass(cellType))
        } else {
            register(cellType, forCellReuseIdentifier: NSStringFromClass(cellType))
        }
    }
    
    func dequeueReusableCell<T : UITableViewCell>(_ cellType: T.Type, indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withIdentifier: NSStringFromClass(cellType), for: indexPath) as? T {
            return cell
        } else {
            fatalError("没有注册\(cellType)")
        }
    }
}
