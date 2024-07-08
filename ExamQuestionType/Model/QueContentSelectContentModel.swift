//
//  QueContentSelectContentModel.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/07/09.
//

import UIKit

class QueContentSelectContentModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentSelectContentCell.self
    }
    
    var contentInset: UIEdgeInsets = .init(top: 10, left: 0, bottom: 0, right: 0)
    
    let queLevel2: QueLevel2
    
    var fillBlankAttrArr: [NSMutableAttributedString]
    
    var allAttrArr: [NSMutableAttributedString]
    
    var resultAttributed: NSMutableAttributedString

    lazy var paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 5
        return paragraphStyle
    }()
    
    var delegate: QueContentModelDelegate?
    
    init?(queLevel2: QueLevel2, isResult: Bool = false) {
        let no = queLevel2.no ?? ""
        let content = queLevel2.content ?? ""
        let html = no + content
        guard !html.isEmpty else {
            return nil
        }
        self.queLevel2 = queLevel2
        self.allAttrArr = []
        self.fillBlankAttrArr = []
        self.resultAttributed = NSMutableAttributedString()
        super.init()
        
        if isResult {
            resolver(html: html)
        } else {
            resolver(html: html)
        }
        
        // 去掉末尾换行
        while let last = allAttrArr.last, last.string.hasSuffix("\n") {
            last.replaceCharacters(in: .init(location: last.length - 1, length: 1), with: "")
            if last.string.isEmpty {
                allAttrArr.removeLast()
            }
        }
        
        makeResultAttr()
    }
    
    func makeResultAttr() {
        let resultAttributed = NSMutableAttributedString()
        for itemAttrStr in allAttrArr {
            resultAttributed.append(itemAttrStr)
        }
        resultAttributed.addAttribute(.baselineOffset, value: NSNumber(value: 5), range: .init(location: 0, length: resultAttributed.length))
        resultAttributed.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: 0, length: resultAttributed.length))
        self.resultAttributed = resultAttributed
    }
    
    // MARK: - resolver
    func resolver(html: String) {
        let pRegex = try! NSRegularExpression(pattern: "(<blk.*?</blk>)|(<img.*?>)|(<p.*?</p>)")
        
        var lastIndex = 0
        
        pRegex.enumerateMatches(in: html, range: .init(location: 0, length: html.count)) { match, _, _ in
            guard let range = match?.range else { return }
            
            if range.location != lastIndex { // 有未识别内容
                let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: range.location - lastIndex))
            
                allAttrArr.append(noHandleStr.handle(type: [.uTag, .iTag, .bTag] ,fontSize: 18, paragraphStyle: paragraphStyle))
            }
            let tempStr = (html as NSString).substring(with: range)
            if tempStr.hasPrefix("<p") {
                let firstPEnd = (tempStr as NSString).range(of: ">").location + 1
                let content = (tempStr as NSString).substring(with: .init(location: firstPEnd, length: tempStr.count - firstPEnd - 4)) // 去掉<p></p>
                resolver(html: content)
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: 18),
                    .paragraphStyle : paragraphStyle,
                ]))
            } else if tempStr.hasPrefix("<blk") {
                let fillBlankIndex = fillBlankAttrArr.count
                resolverBLK(fillBlankIndex: fillBlankIndex)
            } else if tempStr.hasPrefix("<img") {
                resolverIMG(content: tempStr)
            }
            
            lastIndex = range.location + range.length
        }
        
        if lastIndex < html.count { // 后面有未识别的内容
            let noHandleStr = (html as NSString).substring(with: .init(location: lastIndex, length: html.count - lastIndex))
            
            allAttrArr.append(noHandleStr.handle(type: [.uTag, .iTag, .bTag], fontSize: 18, paragraphStyle: paragraphStyle))
        }
    }
    
    func resolverBLK(fillBlankIndex: Int) {
//        fillBlankAttrStr = .emptyFillBlankAttrStr(index: fillBlankIndex, paragraphStyle: paragraphStyle, needEmptyPlacehold: false)
        let fillBlankAttrStr = NSMutableAttributedString(string: "____", attributes: [
            .font : UIFont.systemFont(ofSize: 18),
            .paragraphStyle : paragraphStyle
        ])
        fillBlankAttrArr.append(fillBlankAttrStr)
        allAttrArr.append(fillBlankAttrStr)
    }
    
    func resolverIMG(content: String) {
        if let imgModels = QueContentImgModel.ImgModel.load(html: content) {
            for imgModel in imgModels {
                
                allAttrArr.append(.init(string: "\n", attributes: [
                    .font : UIFont.systemFont(ofSize: 18),
                    .paragraphStyle : paragraphStyle,
                ]))
                
                allAttrArr.append(.init()) // 占位
                let index = allAttrArr.count - 1
                
                SDWebImageManager.shared.loadImage(with: imgModel.src, progress: nil) { [weak self] img, data, _, _, _, url in
                    print("\(NSStringFromClass(Self.self)) \(#function) 线程: \(Thread.current) 图片链接: \(String(describing: url)) 替换下标: \(index)")
                    guard let self = self, let img = img else { return }
                    let attachment = NSTextAttachment(image: img)
                    let width = imgModel.width ?? img.size.width
                    let height = imgModel.height ?? img.size.height
                    attachment.bounds = .init(x: 0, y: 0, width: width, height: height)
                    
                    let imgAttr = NSMutableAttributedString(attachment: attachment)
                    
                    allAttrArr[index] = imgAttr
                    makeResultAttr()
                    
                    delegate?.contentDidChange(model: self)
                }
            }
        }
    }
}
