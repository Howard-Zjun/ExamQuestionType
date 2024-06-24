//
//  QueContentEssayModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/13.
//

import UIKit

class QueContentEssayModel: NSObject, QueContentModel {

    var cellType: UITableViewCell.Type {
        QueContentEssayCell.self
    }
    
    var contentInset: UIEdgeInsets = .zero
    
    let queLevel2: QueLevel2
    
    let handleModel: QueLevel2
    
    let titleArr: [String]?
    
    init(queLevel2: QueLevel2) {
        guard queLevel2.type == .FillBlank else {
            return nil
        }
        self.queLevel2 = queLevel2
        let handleModel = qst.copy() as! QueLevel2
        self.handleModel = handleModel
        var titleArr: [String] = []

        // 从 contents 中区分描述和问题
        if let content = handleModel.content {
            let data = content.data(using: String.Encoding.utf8)
            let hpple = TFHpple(htmlData: data)
            if let elements = hpple?.search(withXPathQuery: "//p") as? [TFHppleElement] {
                var arr: [String] = []
                for i in 0..<elements.count {
                    let element = elements[i]
                    if element.raw.contains("<blk") {
                        let qst = HtmlUtil.stripBlk(htmlStr: element.content)
                        if qst != "" {
                            titleArr.append(qst)
                            print("titleArr: \(qst)")
                        }
                    } else {
                        arr.append(element.content)
                        print("arr: \(element.content!)")
                    }
                }
                var handleContent = ""
                for (index, str) in arr.enumerated() {
                    if index != arr.count - 1 {
                        handleContent = handleContent + str + "\n"
                    } else {
                        handleContent = handleContent + str
                    }
                }
                handleModel.content = handleContent
            }
        }
        if !titleArr.isEmpty {
            self.titleArr = titleArr
        } else {
            self.titleArr = nil
        }
    }
    
    // 设置答案
    func setAnswer(text: String, index: Int) {
        let titleCount: Int
        if titleArr == nil { // 没有具体题目
            if index > 1 {
                print("\(NSStringFromClass(Self.self)) \(#function) 参数错误")
                return
            }
            titleCount = 1
        } else {
            if index > titleArr!.count {
                print("\(NSStringFromClass(Self.self)) \(#function) 参数错误")
                return
            }
            titleCount = titleArr!.count
        }
        // 这里 correntAnswer 没有内容，所以用题目数做判断
        while let answerCount = qst.userAnswers.count, answerCount < titleCount {
            qst.userAnswers.append("")
        }
        qst.userAnswers[index] = text
    }
    
    func getAnswer(index: Int) -> String {
        let titleCount: Int
        if titleArr == nil { // 没有具体题目, 则只有一个
            if index > 1 {
                fatalError("\(NSStringFromClass(Self.self)) \(#function) 参数错误")
            }
            titleCount = 1
        } else {
            if index > titleArr!.count {
                fatalError("\(NSStringFromClass(Self.self)) \(#function) 参数错误")
            }
            titleCount = titleArr!.count
        }
        while let answerCount = qst.userAnswers.count, answerCount < titleCount {
            qst.userAnswers.append("")
        }
        return qst.userAnswers[index]
    }
}
