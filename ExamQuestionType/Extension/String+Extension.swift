import UIKit

extension String {
    
    func textHeight(textWidth: CGFloat, font: UIFont) -> CGFloat {
        (self as NSString).boundingRect(with: .init(width: textWidth, height: CGFLOAT_MAX), attributes: [.font : font], context: nil).height
    }
    
    func removeSpace() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func handle(fontSize: CGFloat, foregroundColor: UIColor? = nil, paragraphStyle: NSParagraphStyle? = nil, baselineOffset: Int? = nil) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString(string: self, attributes: [
            .font : UIFont.systemFont(ofSize: fontSize)
        ])
        
        attr.handle(fontSize: fontSize, foregroundColor: foregroundColor, paragraphStyle: paragraphStyle, baselineOffset: baselineOffset)
        
        return attr
    }
    
    func fillBlankAttr(font: UIFont, link: String, foregroundColor: UIColor = .black, paragraphStyle: NSParagraphStyle? = nil, underlineColor: UIColor = .black, baselineOffset: Int? = nil) -> NSMutableAttributedString {
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
            .underlineColor : underlineColor,
            .underlineStyle : NSNumber(value: NSUnderlineStyle.single.rawValue),
        ], range: .init(location: 0, length: ret.length))
        
        if let paragraphStyle = paragraphStyle {
            ret.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: ret.length))
        }
        
        if let baselineOffset = baselineOffset {
            ret.addAttribute(.baselineOffset, value: NSNumber(value: baselineOffset), range: .init(location: 0, length: ret.length))
        }
        return ret
    }
}
