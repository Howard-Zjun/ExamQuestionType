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
        let uRegex = try! NSRegularExpression(pattern: "<u>.*?</u>")
        var uOffset = 0

        let attr = NSMutableAttributedString(string: self, attributes: [
            .font : UIFont.systemFont(ofSize: fontSize),
        ])
        
        uRegex.enumerateMatches(in: attr.string, options: [], range: .init(location: 0, length: attr.length)) { match, _, _ in
            if let range = match?.range {
                let originContent = (attr.string as NSString).substring(with: .init(location: uOffset + range.location, length: range.length))
                let content = (originContent as NSString).substring(with: .init(location: 3, length: originContent.count - 3 - 4)) // 去掉前后标签
                
                attr.replaceCharacters(in: .init(location: uOffset + range.location, length: range.length), with: content)

                attr.addAttributes([
                    .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                    .underlineColor : UIColor.black,
                ], range: .init(location: uOffset + range.location, length: content.count))
                
                uOffset = uOffset + (content.count - originContent.count)
            }
        }
        
        let iRegex = try! NSRegularExpression(pattern: "<i>.*?</i>")
        var iOffset = 0
        iRegex.enumerateMatches(in: attr.string, options: [], range: .init(location: 0, length: attr.length)) { match, _, _ in
            if let range = match?.range {
                let originContent = (attr.string as NSString).substring(with: .init(location: iOffset + range.location, length: range.length))
                let content = (originContent as NSString).substring(with: .init(location: 3, length: originContent.count - 3 - 4)) // 去掉前后标签
                
                attr.replaceCharacters(in: .init(location: iOffset + range.location, length: range.length), with: content)

                attr.addAttributes([
                    .obliqueness : NSNumber(value: 0.5),
                ], range: .init(location: iOffset + range.location, length: content.count))
                
                iOffset = iOffset + (content.count - originContent.count)
            }
        }
        
        let bRegex = try! NSRegularExpression(pattern: "<b>.*?</b>")
        var bOffset = 0
        bRegex.enumerateMatches(in: attr.string, options: [], range: .init(location: 0, length: attr.length)) { match, _, _ in
            if let range = match?.range {
                let originContent = (attr.string as NSString).substring(with: .init(location: bOffset + range.location, length: range.length))
                let content = (originContent as NSString).substring(with: .init(location: 3, length: originContent.count - 3 - 4)) // 去掉前后标签
                
                attr.replaceCharacters(in: .init(location: bOffset + range.location, length: range.length), with: content)

                attr.addAttributes([
                    .font : UIFont.systemFont(ofSize: fontSize, weight: .bold),
                ], range: .init(location: bOffset + range.location, length: content.count))
                
                bOffset = bOffset + (content.count - originContent.count)
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
