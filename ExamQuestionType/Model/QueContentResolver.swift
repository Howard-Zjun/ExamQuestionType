import UIKit

class QueContentResolver {
    
    /// 将 QueContentDescribeModel 整合
    static func fixDescribe(contentModels: [QueContentModel]) -> [QueContentModel] {
        var right = 0
        var retModels: [QueContentModel] = []
        var contentAttr = NSMutableAttributedString()
        
        func finishDescribe() {
            if !contentAttr.string.isEmpty {
                while contentAttr.string.hasPrefix("\n") {
                    contentAttr.replaceCharacters(in: .init(location: 0, length: 1), with: "")
                }
                while contentAttr.string.hasSuffix("\n") {
                    contentAttr.replaceCharacters(in: .init(location: contentAttr.length - 1, length: 1), with: "")
                }
                if !contentAttr.string.isEmpty {
                    let describeModel = QueContentDescribeModel(attr: contentAttr)
                    retModels.append(describeModel)
                }
                
                contentAttr = .init()
            }
        }
        
        while right < contentModels.count {
            if let describeModel = contentModels[right] as? QueContentDescribeModel {
                contentAttr.append(describeModel.handleContentAttr)
            } else {
                finishDescribe()
                retModels.append(contentModels[right])
            }
            right += 1
        }
        finishDescribe()
        
        return retModels
    }
    
    static func normalResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        var models: [QueContentModel] = []
        let no = Tool.noHandle(no: question.no)
        // 题号不参与 HTML 解析，避免 libxml2 将前缀补成独立段落。
        if !no.isEmpty, let model = QueContentDescribeModel(html: no) {
            models.append(model)
        }
        models += normalResolver(question: question, html: question.content ?? "", isResult: isResult)
        return fixDescribe(contentModels: models)
    }

    static func normalResolver(question: QuestionNode, html: String, isResult: Bool) -> [QueContentModel] {
        resolveHTML(question: question, html: html, essayOffset: nil, isResult: isResult)
    }

    /// 普通题面与作文共用节点遍历；essayOffset 为 nil 时将空位作为普通下划线展示。
    private static func resolveHTML(question: QuestionNode, html: String, essayOffset: Int?, isResult: Bool) -> [QueContentModel] {
        guard let document = try? HTMLDocument(html: html), let root = document.body ?? document.root else { return [] }

        var models: [QueContentModel] = []
        // 整棵节点树共用一个索引，避免进入新段落后重复使用前面的答案位置。
        var essayIndex = essayOffset
        let inlineTags: Set<String> = ["b", "strong", "i", "em", "u", "a", "sup", "sub"]

        func appendText(_ text: String, tags: [String], alignment: NSTextAlignment?) {
            guard !text.isEmpty else { return }
            // 节点已经是解码后的文本，直接构建富文本，避免重新解析丢失空格或解释字面标签。
            let fontSize: CGFloat = 18
            let baselineOffset = 5
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 5
            paragraphStyle.paragraphSpacing = 5
            if let alignment = alignment {
                paragraphStyle.alignment = alignment
            }
            var attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize),
                .baselineOffset: NSNumber(value: baselineOffset),
                .paragraphStyle: paragraphStyle
            ]
            if tags.contains("u") {
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                attributes[.underlineColor] = UIColor.black
            }
            if tags.contains("i") || tags.contains("em") {
                attributes[.obliqueness] = NSNumber(value: 0.5)
            }
            if tags.contains("b") || tags.contains("strong") {
                attributes[.font] = UIFont.systemFont(ofSize: fontSize, weight: .bold)
            }
            if tags.contains("sup") {
                attributes[.font] = UIFont.systemFont(ofSize: fontSize * 0.5)
                attributes[.baselineOffset] = NSNumber(value: baselineOffset + Int(ceil(fontSize * 1.5)))
            }
            if tags.contains("sub") {
                attributes[.font] = UIFont.systemFont(ofSize: fontSize * 0.5)
            }
            let content = NSMutableAttributedString(string: text, attributes: attributes)
            models.append(QueContentDescribeModel(attr: content))
        }

        func resolve(_ node: HTMLNode, tags: [String] = [], alignment: NSTextAlignment? = nil) {
            if node.kind == .text || node.kind == .cdata {
                appendText(node.text ?? "", tags: tags, alignment: alignment)
                return
            }
            guard node.kind == .element else { return }

            switch node.name {
            case "p":
                var paragraphAlignment = alignment
                switch node.attribute(named: "align")?.lowercased() {
                case "left": paragraphAlignment = .left
                case "center": paragraphAlignment = .center
                case "right": paragraphAlignment = .right
                case "justify": paragraphAlignment = .justified
                default: break
                }
                for child in node.children {
                    resolve(child, tags: tags, alignment: paragraphAlignment)
                }
                appendText("\n", tags: [], alignment: paragraphAlignment)
            case "table":
                // 表格交给现有模型整体处理，不重复展开内部节点。
                if let html = node.outerHTML,
                   let model = QueContentTableModel(question: question, html: html, isResult: isResult) {
                    models.append(model)
                }
            case "img":
                if let src = node.attribute(named: "src"), let url = URL(string: src) {
                    let width = node.attribute(named: "width").flatMap { Float($0) }.map { CGFloat($0) }
                    let height = node.attribute(named: "height").flatMap { Float($0) }.map { CGFloat($0) }
                    let image = QueContentImgModel.ImgModel(src: url, width: width, height: height)
                    models.append(QueContentImgModel(model: image))
                }
            case "blk":
                if let index = essayIndex {
                    if let model = QueContentEssayModel(question: question, index: index, isResult: isResult) {
                        models.append(model)
                        essayIndex = index + 1
                    }
                } else {
                    appendText("____", tags: tags, alignment: alignment)
                }
            case "br":
                appendText("\n", tags: tags, alignment: alignment)
            case "head", "script", "style":
                break
            default:
                let childTags = node.name.flatMap { inlineTags.contains($0) ? tags + [$0] : nil } ?? tags
                for child in node.children {
                    resolve(child, tags: childTags, alignment: alignment)
                }
            }
        }

        resolve(root)
        return models
    }

    static func essayResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        var models: [QueContentModel] = []
        let no = Tool.noHandle(no: question.no)
        if !no.isEmpty, let model = QueContentDescribeModel(html: no) {
            models.append(model)
        }
        models += essayResolver(question: question, html: question.content ?? "", essayOffset: 0, isResult: isResult)
        return fixDescribe(contentModels: models)
    }

    static func essayResolver(question: QuestionNode, html: String, essayOffset: Int, isResult: Bool) -> [QueContentModel] {
        resolveHTML(question: question, html: html, essayOffset: essayOffset, isResult: isResult)
    }

    static func fillBlankResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        if let tableFillBlankModel = QueContentTableModel(question: question, isResult: isResult) {
            retModels.append(tableFillBlankModel)
        } else if let fillBlankModel = QueContentFillBlankModel(question: question, isResult: isResult) {
            retModels.append(fillBlankModel)
        }
        
        return retModels
    }
    
    static func selectFillBlankResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        if let selectFillBlankModel = QueContentSelectFillBlankModel(question: question, isResult: isResult) {
            retModels.append(selectFillBlankModel)
        }
        return retModels
    }
    
    static func selectResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        var retModels: [QueContentModel] = []
        
        retModels += normalResolver(question: question, isResult: isResult)
        if let selectOptionModel = QueContentSelectOptionModel(question: question, isResult: isResult) {
            retModels.append(selectOptionModel)
        }
        
        return retModels
    }
    
    static func conversationResolver(question: QuestionNode, isResult: Bool = false) -> [QueContentModel] {
        let retModels = normalResolver(question: question, isResult: isResult)
        
        return retModels
    }
}
