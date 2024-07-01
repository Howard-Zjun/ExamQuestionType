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
    
    static func emptyFillBlankAttrStr(index: Int, isFocus: Bool = false) -> NSMutableAttributedString {
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
    func handleUIB(fontSize: CGFloat) -> NSMutableAttributedString {
        let regex = try! NSRegularExpression(pattern: "(<u>)|(</u>)|(<i>)|(</i>)|(<b>)|(</b>)")
        var uArr: [Int] = []
        var iArr: [Int] = []
        var bArr: [Int] = []
        var locationOffset = 0
        
        var text = self
        regex.enumerateMatches(in: text, options: [], range: .init(location: 0, length: text.count)) { match, _, _ in
            if let range = match?.range {
                let subStr = (text as NSString).substring(with: range)
                if subStr.contains("u") {
                    uArr.append(locationOffset + range.location)
                } else if subStr.contains("i") {
                    iArr.append(locationOffset + range.location)
                } else if subStr.contains("b") {
                    bArr.append(locationOffset + range.location)
                }
                text = (text as NSString).replacingCharacters(in: range, with: "")
                locationOffset -= range.length
            }
        }
        
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font : UIFont.systemFont(ofSize: fontSize),
            .foregroundColor : UIColor.black,
            .paragraphStyle : paragraphStyle,
            .baselineOffset : NSNumber(value: 5)
        ])
    
        var uindex = 1
        while uindex < uArr.count {
            let start = uArr[uindex - 1]
            let end = uArr[uindex]
            attr.addAttributes([
                .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
                .underlineColor : UIColor.black
            ], range: .init(location: start, length: end - start))
            uindex += 2
        }
        
        var iindex = 1
        while iindex < iArr.count {
            let start = iArr[iindex - 1]
            let end = iArr[iindex]
            attr.addAttributes([
                .obliqueness : NSNumber(value: 0.5)
            ], range: .init(location: start, length: end - start))
            iindex += 2
        }
        
        var bindex = 1
        while bindex < bArr.count {
            let start = bArr[bindex - 1]
            let end = bArr[bindex]
            attr.addAttributes([
                .font : UIFont.systemFont(ofSize: fontSize, weight: .bold)
            ], range: .init(location: start, length: end - start))
            bindex += 2
        }
        
        return attr
    }
}

extension UITableView {
    
//    func register<T : UITableViewCell.Type>(_ cellType: T) {
//        if let nib = UINib(nibName: NSStringFromClass(cellType), bundle: nil) {
//            register(nib, forCellReuseIdentifier: NSStringFromClass(cellType))
//        } else {
//            register(cellType, forCellReuseIdentifier: NSStringFromClass(cellType))
//        }
//    }
//    
//    func dequeueReusableCell<T : UITableViewCell>(_ cellType: T, indexPath: IndexPath) -> T {
//        if let cell = dequeueReusableCell(withIdentifier: NSStringFromClass(cellType), for: indexPath) as? T {
//            return cell
//        } else {
//            fatalError("没有注册\(cellType)")
//        }
//    }
}
