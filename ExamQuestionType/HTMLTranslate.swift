//
//  HTMLTranslate.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/23.
//

import UIKit

class HTMLTranslate: NSObject {

    static func stripBlk(html: String) -> String? {
        guard let data = html.data(using: .utf8) else { return nil }
        
        var ret = ""
        
        let hpple = TFHpple(data: data, isXML: false)
        let elements = hpple?.search(withXPathQuery: "//p") as! [TFHppleElement]
        
        for element in elements {
            if element.raw == "blk" {
                ret += "___"
            } else if element.raw == "text" {
                ret += element.content + "\n'"
            }
        }
        return ret
    }
}
