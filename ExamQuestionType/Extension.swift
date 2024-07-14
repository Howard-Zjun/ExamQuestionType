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
    static let aTag = HandleType(rawValue: 1 << 5)
    static let strongTag = HandleType(rawValue: 1 << 6)
}

extension String {
    
    func textHeight(textWidth: CGFloat, font: UIFont) -> CGFloat {
        (self as NSString).boundingRect(with: .init(width: textWidth, height: CGFLOAT_MAX), attributes: [.font : font], context: nil).height
    }
    
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
    
    func fillBlankAttr(font: UIFont, link: String, foregroundColor: UIColor = .black, paragraphStyle: NSParagraphStyle? = nil, isFocus: Bool = false) -> NSMutableAttributedString {
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
            .underlineColor : isFocus ? UIColor(hex: 0x2F81FB) : UIColor.black,
            .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
        ], range: .init(location: 0, length: ret.length))
        
        if let paragraphStyle = paragraphStyle {
            ret.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: ret.length))
        }
        
        return ret
    }
    
    /// 文本对齐方式
    func resolverPAligment() -> NSTextAlignment? {
        if hasPrefix("<p"), let data = self.data(using: .utf8), let hpple = TFHpple(data: data, isXML: false), let element = (hpple.search(withXPathQuery: "//p") as? [TFHppleElement])?.first {
            if let align = element.attributes["align"] as? String {
                if align.lowercased() == "right" {
                    return .right
                } else if align.lowercased() == "left" {
                    return .left
                }
            }
        }
        return nil
    }
}

extension NSMutableAttributedString {
       
    func textHeight(textWidth: CGFloat) -> CGFloat {
        self.boundingRect(with: .init(width: textWidth, height: 2000), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height
    }
    
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
        
        if self.string.contains("<u") && type.contains(.uTag) {
            handleU()
        }
        if self.string.contains("<i") && type.contains(.iTag) {
            handleI()
        }
        if self.string.contains("<blk") && type.contains(.blk) {
            handleBLK()
        }
        if self.string.contains("<br") && type.contains(.br) {
            handleBr()
        }
        if self.string.contains("<b") && type.contains(.bTag) {
            handleB(fontSize: fontSize)
        }
        if self.string.contains("<a") && type.contains(.aTag) {
            handleA()
        }
        if self.string.contains("<strong") && type.contains(.strongTag) {
            handleStrong(fontSize: fontSize)
        }
    }
    
    func handleU() {
        let uRegex = try! NSRegularExpression(pattern: "<u.*?</u>", options: .dotMatchesLineSeparators)
        var uOffset = 0
        
        let ranges = uRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let originContent = (self.string as NSString).substring(with: .init(location: uOffset + range.location, length: range.length))
            let firstEnd = (originContent as NSString).range(of: ">").location + 1
            var content = (originContent as NSString).substring(with: .init(location: firstEnd, length: originContent.count - firstEnd - 4)) // 去掉前后标签
            
            var needClearColor = false
            if content.removeSpace().isEmpty {
                content = spaceStr
                needClearColor = true
            }
            self.replaceCharacters(in: .init(location: uOffset + range.location, length: range.length), with: content)

            self.addAttributes([
                .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor.black,
            ], range: .init(location: uOffset + range.location, length: content.count))
            
            if needClearColor {
                self.addAttributes([
                    .foregroundColor : UIColor.clear
                ], range: .init(location: uOffset + range.location, length: content.count))
            }
            
            uOffset = uOffset + (content.count - originContent.count)
        }
    }
    
    func handleI() {
        let iRegex = try! NSRegularExpression(pattern: "<i.*?</i>", options: .dotMatchesLineSeparators)
        var iOffset = 0
        
        let ranges = iRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let originContent = (self.string as NSString).substring(with: .init(location: iOffset + range.location, length: range.length))
            let firstEnd = (originContent as NSString).range(of: ">").location + 1
            let content = (originContent as NSString).substring(with: .init(location: firstEnd, length: originContent.count - firstEnd - 4)) // 去掉前后标签
            
            self.replaceCharacters(in: .init(location: iOffset + range.location, length: range.length), with: content)

            self.addAttributes([
                .obliqueness : NSNumber(value: 0.5),
            ], range: .init(location: iOffset + range.location, length: content.count))
            
            iOffset = iOffset + (content.count - originContent.count)
        }
    }
    
    func handleB(fontSize: CGFloat) {
        let bRegex = try! NSRegularExpression(pattern: "<b.*?</b>", options: .dotMatchesLineSeparators)
        var bOffset = 0
        
        let ranges = bRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let originContent = (self.string as NSString).substring(with: .init(location: bOffset + range.location, length: range.length))
            let firstEnd = (originContent as NSString).range(of: ">").location + 1
            let content = (originContent as NSString).substring(with: .init(location: firstEnd, length: originContent.count - firstEnd - 4)) // 去掉前后标签
            
            self.replaceCharacters(in: .init(location: bOffset + range.location, length: range.length), with: content)

            self.addAttributes([
                .font : UIFont.systemFont(ofSize: fontSize, weight: .bold),
            ], range: .init(location: bOffset + range.location, length: content.count))
            
            bOffset = bOffset + (content.count - originContent.count)
        }
    }
    
    func handleBLK() {
        let blkRegex = try! NSRegularExpression(pattern: "(<blk.*?/>)|(<blk.*?</blk>)", options: .dotMatchesLineSeparators)
        var blkOffset = 0
        
        let ranges = blkRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let content = "____"
            
            self.replaceCharacters(in: .init(location: blkOffset + range.location, length: range.length), with: content)
            
            blkOffset = blkOffset + (content.count - range.length)
        }
    }
    
    func handleBr() {
        let brRegex = try! NSRegularExpression(pattern: "<br.*?/>", options: .dotMatchesLineSeparators)
        var brOffset = 0
        
        let ranges = brRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let content = "\n"
            
            self.replaceCharacters(in: .init(location: brOffset + range.location, length: range.length), with: content)
            
            brOffset = brOffset + (content.count - range.length)
        }
    }
    
    func handleA() {
        let aRegex = try! NSRegularExpression(pattern: "<a.*?</a>", options: .dotMatchesLineSeparators)
        var aOffset = 0
        
        let ranges = aRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let originContent = (self.string as NSString).substring(with: .init(location: aOffset + range.location, length: range.length))
            let firstEnd = (originContent as NSString).range(of: ">").location + 1
            let content = (originContent as NSString).substring(with: .init(location: firstEnd, length: originContent.count - firstEnd - 4)) // 去掉前后标签
            
            self.replaceCharacters(in: .init(location: aOffset + range.location, length: range.length), with: content)

            self.addAttributes([
                .foregroundColor : UIColor(hex: 0x2BF1D1),
                .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor(hex: 0x2CF1B6)
            ], range: .init(location: aOffset + range.location, length: content.count))
            
            aOffset = aOffset + (content.count - originContent.count)
        }
    }
    
    func handleStrong(fontSize: CGFloat) {
        let sRegex = try! NSRegularExpression(pattern: "<strong.*?</strong>", options: .dotMatchesLineSeparators)
        var sOffset = 0
        
        let ranges = sRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let originContent = (self.string as NSString).substring(with: .init(location: sOffset + range.location, length: range.length))
            let firstEnd = (originContent as NSString).range(of: ">").location + 1
            let content = (originContent as NSString).substring(with: .init(location: firstEnd, length: originContent.count - firstEnd - 9)) // 去掉前后标签
            
            self.replaceCharacters(in: .init(location: sOffset + range.location, length: range.length), with: content)

            self.addAttributes([
                .font : UIFont.systemFont(ofSize: fontSize, weight: .bold),
            ], range: .init(location: sOffset + range.location, length: content.count))
            
            sOffset = sOffset + (content.count - originContent.count)
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

extension UICollectionView {
    
    func register<T : UICollectionViewCell>(_ cellType: T.Type) {
        if Bundle.main.path(forResource: String(describing: cellType), ofType: "nib")?.first != nil {
            register(.init(nibName: String(describing: cellType), bundle: nil), forCellWithReuseIdentifier: NSStringFromClass(cellType))
        } else {
            register(cellType, forCellWithReuseIdentifier: NSStringFromClass(cellType))
        }
    }
    
    func dequeueReusableCell<T : UICollectionViewCell>(_ cellType: T.Type, indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withReuseIdentifier: NSStringFromClass(cellType), for: indexPath) as? T {
            return cell
        } else {
            fatalError("没有注册\(cellType)")
        }
    }
}
