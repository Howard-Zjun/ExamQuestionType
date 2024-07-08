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

struct HandleType: OptionSet {
    let rawValue: UInt
    
    static let uTag = HandleType(rawValue: 1 << 0)
    static let iTag = HandleType(rawValue: 1 << 1)
    static let bTag = HandleType(rawValue: 1 << 2)
    static let br = HandleType(rawValue: 1 << 3)
    static let blk = HandleType(rawValue: 1 << 4)
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
    
    func handle(type: HandleType, fontSize: CGFloat, foregroundColor: UIColor? = nil, paragraphStyle: NSParagraphStyle? = nil, baselineOffset: Int? = nil) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString(string: self, attributes: [
            .font : UIFont.systemFont(ofSize: fontSize)
        ])
        
        attr.handle(type: type, fontSize: fontSize, foregroundColor: foregroundColor, paragraphStyle: paragraphStyle, baselineOffset: baselineOffset)
        
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

extension NSMutableAttributedString {
       
    static func emptyFillBlankAttrStr(index: Int, paragraphStyle: NSParagraphStyle? = nil, needEmptyPlacehold: Bool = true) -> NSMutableAttributedString {
        // 只能逐个添加，使用 addAttribute 添加附件没有效果
        let ret = NSMutableAttributedString()
        ret.append(.init(string: "⌘"))
        
        if needEmptyPlacehold {
            let attachment = NSTextAttachment(image: .init(named: "blank_icon_edit")!)
            attachment.bounds = .init(x: 0, y: 0, width: 18, height: 18)
            ret.append(.init(attachment: attachment))
        } else {
            ret.append(.init(string: "⌘"))
        }
        
        ret.append(.init(string: "⌘"))
        
        ret.addAttributes([
            .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
            .underlineColor : UIColor.black,
            .link : "\(snFillBlankURLPrefix)\(snSeparate)\(index)",
            .font : UIFont.systemFont(ofSize: 18),
            .foregroundColor : UIColor.clear,
        ], range: .init(location: 0, length: ret.length))
        
        if let paragraphStyle = paragraphStyle {
            ret.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: ret.length))
        }
        return ret
    }
    
    func handle(type: HandleType, fontSize: CGFloat, foregroundColor: UIColor? = nil, paragraphStyle: NSParagraphStyle? = nil, baselineOffset: Int? = nil) {
        if type.contains(.uTag) {
            handleU()
        }
        if type.contains(.iTag) {
            handleI()
        }
        if type.contains(.bTag) {
            handleB(fontSize: fontSize)
        }
        if type.contains(.blk) {
            handleBLK()
        }
        if type.contains(.br) {
            handleBr()
        }
        
        self.addAttributes([
            .font : UIFont.systemFont(ofSize: fontSize)
        ], range: .init(location: 0, length: self.length))
        
        if let foregroundColor = foregroundColor {
            self.addAttributes([
                .foregroundColor : foregroundColor,
            ], range: .init(location: 0, length: self.length))
        }
        
        if let paragraphStyle = paragraphStyle {
            self.addAttributes([
                .paragraphStyle : paragraphStyle
            ], range: .init(location: 0, length: self.length))
        }
        
        if let baselineOffset = baselineOffset {
            self.addAttributes([
                .baselineOffset : NSNumber(value: baselineOffset),
            ], range: .init(location: 0, length: self.length))
        }
    }
    
    func handleU() {
        let uRegex = try! NSRegularExpression(pattern: "<u.*?</u>")
        var uOffset = 0
        
        uRegex.enumerateMatches(in: self.string, options: [], range: .init(location: 0, length: self.length)) { match, _, _ in
            if let range = match?.range {
                let originContent = (self.string as NSString).substring(with: .init(location: uOffset + range.location, length: range.length))
                let content = (originContent as NSString).substring(with: .init(location: 3, length: originContent.count - 3 - 4)) // 去掉前后标签
                
                self.replaceCharacters(in: .init(location: uOffset + range.location, length: range.length), with: content)

                self.addAttributes([
                    .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                    .underlineColor : UIColor.black,
                ], range: .init(location: uOffset + range.location, length: content.count))
                
                uOffset = uOffset + (content.count - originContent.count)
            }
        }
    }
    
    func handleI() {
        let iRegex = try! NSRegularExpression(pattern: "<i.*?</i>")
        var iOffset = 0
        
        iRegex.enumerateMatches(in: self.string, options: [], range: .init(location: 0, length: self.length)) { match, _, _ in
            if let range = match?.range {
                let originContent = (self.string as NSString).substring(with: .init(location: iOffset + range.location, length: range.length))
                let content = (originContent as NSString).substring(with: .init(location: 3, length: originContent.count - 3 - 4)) // 去掉前后标签
                
                self.replaceCharacters(in: .init(location: iOffset + range.location, length: range.length), with: content)

                self.addAttributes([
                    .obliqueness : NSNumber(value: 0.5),
                ], range: .init(location: iOffset + range.location, length: content.count))
                
                iOffset = iOffset + (content.count - originContent.count)
            }
        }
    }
    
    func handleB(fontSize: CGFloat) {
        let bRegex = try! NSRegularExpression(pattern: "<b.*?</b>")
        var bOffset = 0
        
        bRegex.enumerateMatches(in: self.string, options: [], range: .init(location: 0, length: self.length)) { match, _, _ in
            if let range = match?.range {
                let originContent = (self.string as NSString).substring(with: .init(location: bOffset + range.location, length: range.length))
                let content = (originContent as NSString).substring(with: .init(location: 3, length: originContent.count - 3 - 4)) // 去掉前后标签
                
                self.replaceCharacters(in: .init(location: bOffset + range.location, length: range.length), with: content)

                self.addAttributes([
                    .font : UIFont.systemFont(ofSize: fontSize, weight: .bold),
                ], range: .init(location: bOffset + range.location, length: content.count))
                
                bOffset = bOffset + (content.count - originContent.count)
            }
        }
    }
    
    func handleBLK() {
        let blkRegex = try! NSRegularExpression(pattern: "(<blk.*?/>)|(<blk.*?</blk>)")
        var blkOffset = 0
        
        blkRegex.enumerateMatches(in: self.string, options: [], range: .init(location: 0, length: self.length)) { match, _, _ in
            if let range = match?.range {
                let content = "___"
                
                self.replaceCharacters(in: .init(location: blkOffset + range.location, length: range.length), with: content)
                
                blkOffset = blkOffset + (content.count - range.length)
            }
        }
    }
    
    func handleBr() {
        let brRegex = try! NSRegularExpression(pattern: "<br/>")
        var brOffset = 0
        
        brRegex.enumerateMatches(in: self.string, range: .init(location: 0, length: self.length)) { match, _, _ in
            if let range = match?.range {
                
                let content = "\n"
                
                self.replaceCharacters(in: .init(location: brOffset + range.location, length: range.length), with: content)
                
                brOffset = brOffset + (content.count - range.length)
            }
        }
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
