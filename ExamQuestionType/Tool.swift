//
//  Tool.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/23.
//

import UIKit

class Tool: NSObject {

    static func positionToLetter(position: Int) -> String {
        let aStr: NSString = "A"
        return String(format: "%c", aStr.character(at: 0) + position)
    }
    
    static func letterToPosition(letter: String) -> Int {
        let aStr: NSString = "A"
        return (letter as NSString).character(at: 0) - aStr.character(at: 0)
    }
}
