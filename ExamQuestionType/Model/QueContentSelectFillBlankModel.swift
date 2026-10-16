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
    
    init?(question: QuestionNode, isResult: Bool = false, inSelectFillBlank: Int = 0) {
        let no = Tool.noHandle(no: question.no)
        let content = question.content ?? ""
        let html = no + content
        guard question.type == .SelectFillBlank, !html.isEmpty else {
            return nil
        }
        
        var options: [[String]] = []
        if question.isNormal {
            for _ in 0..<(question.correctAnswers?.count ?? 0) {
                options.append(question.options ?? [])
            }
            
        } else {
            for item in question.subquestions ?? [] {
                options.append(item.options ?? [])
            }
        }
        self.options = options
        super.init(question: question, isResult: isResult)

        var userAnswers: [String] = []
        var correctAnswers: [String]?
        if question.isNormal {
            userAnswers = question.userAnswers
            correctAnswers = question.correctAnswers
        } else {
            userAnswers = question.subquestions?.map({ $0.userAnswers.first ?? "" }) ?? []
            correctAnswers = question.subquestions?.flatMap({ $0.correctAnswers ?? [] })
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
