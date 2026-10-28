import UIKit

extension NSMutableAttributedString {
       
    func textHeight(textWidth: CGFloat, withFont: UIFont) -> CGFloat {
        if let tmp = self.mutableCopy() as? NSMutableAttributedString {
            tmp.setAttributes([.font : withFont], range: .init(location: 0, length: tmp.length))
            return tmp.textHeight(textWidth: textWidth)
        } else {
            return textHeight(textWidth: textWidth)
        }
    }
    
    func textHeight(textWidth: CGFloat) -> CGFloat {
        self.boundingRect(with: .init(width: textWidth, height: 2000), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size.height
    }
    
    static func emptyFillBlankAttrWithIcon(index: Int, paragraphStyle: NSParagraphStyle? = nil, baselineOffset: Int? = nil) -> NSMutableAttributedString {
        // 只能逐个添加，使用 addAttribute 添加附件没有效果
        let ret = NSMutableAttributedString()
        ret.append(.init(string: "⌘"))
        
        let attachment = NSTextAttachment(image: .init(named: "blank_icon_edit")!)
        attachment.bounds = .init(x: 0, y: 0, width: 18, height: 18)
        ret.append(.init(attachment: attachment))
        
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
        
        if let baselineOffset = baselineOffset {
            ret.addAttribute(.baselineOffset, value: NSNumber(value: baselineOffset), range: .init(location: 0, length: ret.length))
        }
        return ret
    }
    
    static func emptyFillBlankAttr(index: Int, paragraphStyle: NSParagraphStyle? = nil, baselineOffset: Int? = nil) -> NSMutableAttributedString {
        // 只能逐个添加，使用 addAttribute 添加附件没有效果
        let ret = NSMutableAttributedString()
        ret.append(.init(string: "⌘"))
        
        ret.append(.init(string: "⌘"))
        
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
        
        if let baselineOffset = baselineOffset {
            ret.addAttribute(.baselineOffset, value: NSNumber(value: baselineOffset), range: .init(location: 0, length: ret.length))
        }
        return ret
    }
    
    func handle(fontSize: CGFloat, foregroundColor: UIColor? = nil, paragraphStyle: NSParagraphStyle? = nil, baselineOffset: Int? = nil) {
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
        
        if self.string.contains("<u") {
            handleU()
        }
        if self.string.contains("<i") {
            handleI()
        }
        if self.string.contains("<em") {
            handleEm()
        }
        if self.string.contains("<blk") {
            handleBLK()
        }
        if self.string.contains("<br") {
            handleBr()
        }
        if self.string.contains("<b") {
            handleB(fontSize: fontSize)
        }
        if self.string.contains("<a") {
            handleA()
        }
        if self.string.contains("<strong") {
            handleStrong(fontSize: fontSize)
        }
        if self.string.contains("<sup") {
            handleSup(fontSize: fontSize, baselineOffset: baselineOffset ?? 0)
        }
        if self.string.contains("<sub") {
            handleSub(fontSize: fontSize)
        }
        if self.string.contains("&nbsp;") {
            handle_nbsp()
        }
        if self.string.contains("&amp;") {
            handle_amp()
        }
        if self.string.contains("&quot;") {
            handle_quot()
        }
        if self.string.contains("&apos;") {
            handle_apos()
        }
        // 这两个最后在解析
        if self.string.contains("&lt;") {
            handle_lt()
        }
        if self.string.contains("&gt;") {
            handle_gt()
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
    
    func handleEm() {
        let iRegex = try! NSRegularExpression(pattern: "<em.*?>.*?</em>", options: .dotMatchesLineSeparators)
        var iOffset = 0
        
        let ranges = iRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let originContent = (self.string as NSString).substring(with: .init(location: iOffset + range.location, length: range.length))
            let firstEnd = (originContent as NSString).range(of: ">").location + 1
            let content = (originContent as NSString).substring(with: .init(location: firstEnd, length: originContent.count - firstEnd - 5)) // 去掉前后标签
            
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
    
    func handleSup(fontSize: CGFloat, baselineOffset: Int) {
        let sRegex = try! NSRegularExpression(pattern: "<sup.*?</sup>", options: .dotMatchesLineSeparators)
        var sOffset = 0
        
        let ranges = sRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let originContent = (self.string as NSString).substring(with: .init(location: sOffset + range.location, length: range.length))
            let firstEnd = (originContent as NSString).range(of: ">").location + 1
            let content = (originContent as NSString).substring(with: .init(location: firstEnd, length: originContent.count - firstEnd - 6)) // 去掉前后标签
            
            self.replaceCharacters(in: .init(location: sOffset + range.location, length: range.length), with: content)
            
            self.addAttributes([
                .baselineOffset : NSNumber(value: baselineOffset + Int(ceil(fontSize * 1.5))),
                .font : UIFont.systemFont(ofSize: fontSize * 0.5)
            ], range: .init(location: sOffset + range.location, length: content.count))
            
            sOffset = sOffset + (content.count - originContent.count)
        }
    }
    
    func handleSub(fontSize: CGFloat) {
        let sRegex = try! NSRegularExpression(pattern: "<sub.*?</sub>", options: .dotMatchesLineSeparators)
        var sOffset = 0
        
        let ranges = sRegex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            let originContent = (self.string as NSString).substring(with: .init(location: sOffset + range.location, length: range.length))
            let firstEnd = (originContent as NSString).range(of: ">").location + 1
            let content = (originContent as NSString).substring(with: .init(location: firstEnd, length: originContent.count - firstEnd - 6)) // 去掉前后标签
            
            self.replaceCharacters(in: .init(location: sOffset + range.location, length: range.length), with: content)
            
            self.addAttributes([
                .font : UIFont.systemFont(ofSize: fontSize * 0.5)
            ], range: .init(location: sOffset + range.location, length: content.count))
            
            sOffset = sOffset + (content.count - originContent.count)
        }
    }
    
    func handle_nbsp() {
        let pattern = "&nbsp;"
        
        let content = " "
        handleEntity(pattern: pattern, content: content)
    }
    
    func handle_amp() {
        let pattern = "&amp;"
        
        let content = "&"
        handleEntity(pattern: pattern, content: content)
    }
    
    func handle_quot() {
        let pattern = "&quot;"
        
        let content = "\""
        handleEntity(pattern: pattern, content: content)
    }
    
    func handle_apos() {
        let pattern = "&apos;"
        
        let content = "'"
        handleEntity(pattern: pattern, content: content)
    }
    
    func handle_lt() {
        let pattern = "&lt;"
        
        let content = "<"
        
        handleEntity(pattern: pattern, content: content)
    }
    
    func handle_gt() {
        let pattern = "&gt;"
        
        let content = ">"
        
        handleEntity(pattern: pattern, content: content)
    }
    
    func handleEntity(pattern: String, content: String) {
        let regex = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        
        var offset = 0
        
        let ranges = regex.matches(in: self.string, options: [], range: .init(location: 0, length: self.length)).map({ $0.range })
        for range in ranges {
            self.replaceCharacters(in: .init(location: offset + range.location, length: range.length), with: content)
            
            offset = offset + (content.count - pattern.count)
        }
    }
}

