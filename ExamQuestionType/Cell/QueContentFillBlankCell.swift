//
//  QueContentFillBlankCell.swift
//  ExamQuestionType
//
//  Created by ios on 2024/6/19.
//

import UIKit

/// 不能框选的 textview
class DisRangeAbleTextView: UITextView {
    
    // 取消框选
    override var canBecomeFirstResponder: Bool {
        false
    }
}

class QueContentFillBlankCell: UITableViewCell {

    var observation: NSKeyValueObservation?

    // 用于通知 tableView 更新
    var contentSizeDidChange: ((UITextView) -> Void)?

    var contentModel: QueContentFillBlankModel! {
        didSet {
            textView.attributedText = contentModel.resultAttributed
        }
    }
    
    @IBOutlet weak var textViewHeightContraint: NSLayoutConstraint!
    
    // MARK: - view
    // 用于点击 textView 的填空时，聚焦 textField 来编辑
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.returnKeyType = .done
            textField.delegate = self
            textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        }
    }
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.font = .systemFont(ofSize: 18)
            textView.delegate = self
            textView.isEditable = false
            textView.linkTextAttributes = .init()
            
            observation = textView.observe(\.contentSize, options: .new) { [weak self] textView, change in
                print("\(NSStringFromClass(Self.self)) \(#function): 变化高度\(textView.contentSize)")
                
                self?.textViewHeightContraint.constant = textView.contentSize.height
                self?.contentSizeDidChange?(textView)
            }
        }
    }

    // MARK: - target
    @objc func textDidChange(_ sender: UITextField) {
        print("\(NSStringFromClass(Self.self)) \(#function) text: \(sender.text ?? "")")
        var text = sender.text ?? ""
        if text.contains("⌘") {
            text = text.replacingOccurrences(of: "⌘", with: "")
        }
        contentModel.setAnswer(text: sender.text ?? "")
        textView.attributedText = contentModel.resultAttributed
    }
}

// MARK: - UITextViewDelegate
extension QueContentFillBlankCell: UITextViewDelegate {
 
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("\(NSStringFromClass(Self.self)) \(#function) url: \(URL.absoluteString)")
        if URL.absoluteString.hasPrefix(fillBlankURLPrefix) {
            if let str = URL.absoluteString.components(separatedBy: ":").last, let index = Int(str) {
                contentModel.focunsIndex = index
                textView.attributedText = contentModel.resultAttributed
                
                textField.text = contentModel.getAnswer(index: index)
                
                print("\(NSStringFromClass(Self.self)) \(#function) index: \(index), text: \(textField.text ?? "")")
                
                textField.becomeFirstResponder()
            }
        }
        return false
    }
}

// MARK: - UITextFieldDelegate
extension QueContentFillBlankCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.endEditing(true)
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var answer: String = ""
        if let ans = textField.text {
            answer = answer.replacingOccurrences(of: "⌘", with: "")
            answer = ans.removeSpace()
            answer = answer.removeMiddleSpace()
        }
        contentModel.setAnswer(text: answer)
        contentModel.updateScore()
    }
}

