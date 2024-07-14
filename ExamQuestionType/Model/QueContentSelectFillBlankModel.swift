//
//  QueContentSelectFillBlankModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/13.
//

import UIKit

class QueContentSelectFillBlankModel: QueContentFillBlankModel {

    override var cellType: UITableViewCell.Type {
        QueContentSelectFillBlankCell.self
    }
    
    // 选项
    let options: [[String]]
    
    init?(queLevel2: QueLevel2, isResult: Bool = false, inSelectFillBlank: Int = 0) {
        let no = queLevel2.no ?? ""
        let content = queLevel2.content ?? ""
        let html = no + content
        guard queLevel2.type == .SelectFillBlank, !html.isEmpty else {
            return nil
        }
        
        var options: [[String]] = []
        if queLevel2.isNormal {
            for _ in 0..<(queLevel2.correctAnswers?.count ?? 0) {
                options.append(queLevel2.options ?? [])
            }
            
        } else {
            for item in queLevel2.subLevel2 ?? [] {
                options.append(item.options ?? [])
            }
        }
        self.options = options
        super.init(queLevel2: queLevel2, isResult: isResult)

        var userAnswers: [String] = []
        var correctAnswers: [String]?
        if queLevel2.isNormal {
            userAnswers = queLevel2.userAnswers
            correctAnswers = queLevel2.correctAnswers
        } else {
            userAnswers = queLevel2.subLevel2?.map({ $0.userAnswers.first ?? "" }) ?? []
            correctAnswers = queLevel2.subLevel2?.flatMap({ $0.correctAnswers ?? [] })
        }
        if isResult {
            resolverResult(html: html, userAnswers: userAnswers, correctAnswers: correctAnswers ?? [])
        } else {
            resolver(html: html, userAnswers: userAnswers)
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
    
    func getAnswer(index: Int) -> Int? {
        if let str: String = getAnswer(index: index) {
            return Tool.letterToPosition(letter: str)
        }
        return nil
    }
}
