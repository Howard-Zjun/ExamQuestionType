import Foundation
import libxml2

/// 管理 libxml2 HTML 文档，仅提供节点解析与访问，不生成业务模型或展示属性。
final class HTMLDocument {

    enum ParseError: Error {
        case emptyInput
        case inputTooLarge
        case unableToParse
    }

    private let storage: HTMLDocumentStorage

    init(html: String) throws {
        guard !html.isEmpty else { throw ParseError.emptyInput }
        let bytes = Array(html.utf8CString)
        guard bytes.count - 1 <= Int(Int32.max) else { throw ParseError.inputTooLarge }
        let options = HTML_PARSE_RECOVER.rawValue // 尝试从不规范的 HTML 中恢复，尽可能生成节点树；不保证还原原意。
        // HTML_PARSE_NODEFDTD：文档缺少 DOCTYPE 时，不自动补充默认的文档类型声明。
        // HTML_PARSE_PEDANTIC：启用更严格、细致的解析错误报告，不代表改用严格的 XML 解析规则。
        // HTML_PARSE_NOBLANKS：移除解析器判断为可忽略的空白文本节点；可能影响标签之间的空格，因此这里保留空白。
        // HTML_PARSE_NOIMPLIED：不自动补充隐含的 html、head、body 等元素。
        // HTML_PARSE_COMPACT：紧凑存储较短的文本节点，减少内存开销。
        // HTML_PARSE_IGNORE_ENC：忽略 HTML 文档内部的编码提示，例如 meta 中的编码声明。
            | HTML_PARSE_NONET.rawValue // 禁止解析器通过网络加载外部资源。
            | HTML_PARSE_NOERROR.rawValue // 不输出解析错误信息；解析失败仍通过下方的空指针检查处理。
            | HTML_PARSE_NOWARNING.rawValue // 不输出解析警告信息。
        let document = bytes.withUnsafeBufferPointer { buffer in
            htmlReadMemory(buffer.baseAddress, Int32(bytes.count - 1), nil, "UTF-8", Int32(options))
        }
        guard let document = document else { throw ParseError.unableToParse }
        storage = HTMLDocumentStorage(document: document)
    }

    var root: HTMLNode? {
        guard let node = xmlDocGetRootElement(storage.document) else { return nil }
        return HTMLNode(node: node, storage: storage)
    }

    var body: HTMLNode? {
        firstElement(named: "body")
    }

    /// 按文档顺序查找首个指定名称的元素，查找范围包含根元素。
    func firstElement(named name: String) -> HTMLNode? {
        guard let root = root else { return nil }
        let name = name.lowercased()
        var pending = [root]
        while let node = pending.popLast() {
            if node.kind == .element && node.name == name {
                return node
            }
            pending.append(contentsOf: node.children.reversed())
        }
        return nil
    }
}

/// 对 libxml2 原生节点的封装，持有文档资源以保证节点指针有效。
final class HTMLNode {

    /// 节点类型
    enum Kind {
        case element /// 元素节点，例如 p、img、blk。
        case text /// 普通文本节点，包括仅含空格或换行的文本。
        case cdata /// CDATA 文本节点。
        case comment /// 注释节点。
        case other /// 其他 libxml2 节点类型。
    }

    /// 当前节点的原生指针，由所属文档统一管理内存。
    private let node: xmlNodePtr
    /// 强引用文档资源，避免节点仍在使用时底层文档被释放。
    private let storage: HTMLDocumentStorage

    fileprivate init(node: xmlNodePtr, storage: HTMLDocumentStorage) {
        self.node = node
        self.storage = storage
    }

    /// 当前节点的类型。
    var kind: Kind {
        switch node.pointee.type {
        case XML_ELEMENT_NODE: return .element
        case XML_TEXT_NODE: return .text
        case XML_CDATA_SECTION_NODE: return .cdata
        case XML_COMMENT_NODE: return .comment
        default: return .other
        }
    }

    /// 节点名称；元素节点为标签名，文本节点通常为 text，无名称时返回 nil。
    var name: String? {
        guard let name = node.pointee.name else { return nil }
        return String(cString: name)
    }

    /// 第一个直接子节点；可配合 nextSibling、parent 进行非递归遍历。
    var firstChild: HTMLNode? {
        guard let child = node.pointee.children else { return nil }
        return HTMLNode(node: child, storage: storage)
    }

    /// 按文档顺序返回直接子节点，保留文字与元素的交错顺序及空白文本节点。
    var children: [HTMLNode] {
        var result: [HTMLNode] = []
        var child = node.pointee.children
        while let current = child {
            result.append(HTMLNode(node: current, storage: storage))
            child = current.pointee.next
        }
        return result
    }

    /// 父节点；没有父节点或父节点为文档节点时返回 nil。
    var parent: HTMLNode? {
        guard let parent = node.pointee.parent,
              parent.pointee.type != XML_DOCUMENT_NODE,
              parent.pointee.type != XML_HTML_DOCUMENT_NODE else { return nil }
        return HTMLNode(node: parent, storage: storage)
    }

    /// 仅返回文本或 CDATA 节点的文字，其他类型返回 nil。
    /// 内容由 libxml2 解码，不裁剪空白，也不转换富文本样式。
    var text: String? {
        guard kind == .text || kind == .cdata else { return nil }
        return readAndFree(xmlNodeGetContent(node))
    }

    /// 获取节点内容；对元素节点，会合并后代节点的文字，不保留标签边界。
    /// 需要保留文字和标签的交错关系时，应遍历 children。
    var textContent: String {
        readAndFree(xmlNodeGetContent(node)) ?? ""
    }

    /// 元素节点的属性名与解码后属性值；非元素节点返回空字典。
    var attributes: [String: String] {
        guard kind == .element else { return [:] }
        var result: [String: String] = [:]
        var property = node.pointee.properties
        while let current = property {
            if let name = current.pointee.name {
                result[String(cString: name)] = readAndFree(xmlGetProp(node, name)) ?? ""
            }
            property = current.pointee.next
        }
        return result
    }

    func attribute(named name: String) -> String? {
        guard kind == .element else { return nil }
        return name.utf8CString.withUnsafeBufferPointer { buffer in
            let name = UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(to: xmlChar.self)
            return readAndFree(xmlGetProp(node, name))
        }
    }

    /// 将当前节点及其子节点序列化为 HTML，失败时返回 nil。
    /// 结果基于解析后的节点树，可能经过规范化，不保证与原始源码逐字节一致。
    var outerHTML: String? {
        guard let buffer = xmlBufferCreate() else { return nil }
        defer { xmlBufferFree(buffer) }
        guard htmlNodeDump(buffer, storage.document, node) >= 0,
              let content = xmlBufferContent(buffer) else { return nil }
        return String(cString: content)
    }

    private func readAndFree(_ value: UnsafeMutablePointer<xmlChar>?) -> String? {
        guard let value = value else { return nil }
        defer { xmlFree(value) }
        return String(cString: value)
    }

    /// 按文档顺序返回当前节点及其后代中匹配标签名的所有元素，标签名不区分大小写。
    func allMatchNode(tagName: String) -> [HTMLNode] {
        guard !tagName.isEmpty else { return [] }
        let tagName = tagName.lowercased()
        var pending = [self]
        var matches: [HTMLNode] = []
        while let current = pending.popLast() {
            if current.kind == .element && current.name == tagName {
                matches.append(current)
            }
            pending.append(contentsOf: current.children.reversed())
        }
        return matches
    }
}

/// 节点持有文档资源，资源不反向持有节点封装，避免循环引用。
fileprivate final class HTMLDocumentStorage {
    let document: xmlDocPtr

    init(document: xmlDocPtr) {
        self.document = document
    }

    deinit {
        xmlFreeDoc(document)
    }
}
