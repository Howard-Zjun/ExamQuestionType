//
//  Tool.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/23.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.width

let kScreenHeight = UIScreen.main.bounds.height

var kKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }.first?.windows
        .filter { $0.isKeyWindow }.first
}

class Tool: NSObject {

    static func positionToLetter(position: Int) -> String {
        let aStr: NSString = "A"
        return String(format: "%c", Int(aStr.character(at: 0)) + position)
    }
    
    static func letterToPosition(letter: String) -> Int {
        let aStr: NSString = "A"
        return Int((letter as NSString).character(at: 0) - aStr.character(at: 0))
    }
    
    static func noHandle(no: String?) -> String {
        if let no = no {
            return no + "、"
        }
        return ""
    }
}
