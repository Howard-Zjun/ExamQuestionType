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
    var contentSizeWillChange: (() -> Void)?
    
    var contentSizeDidChange: (() -> Void)?

    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!

    var model: QueContentFillBlankModel! {
        didSet {
            model.delegate = self
            textViewTop.constant = model.contentInset.top
            textViewBottom.constant = model.contentInset.bottom
            textView.attributedText = model.resultAttributed
            textViewHeight.constant = textView.contentSize.height
        }
    }
    
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
                guard let self = self else { return }
                print("\(NSStringFromClass(Self.self)) \(#function): 变化高度\(textView.contentSize)")
                
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                perform(#selector(responseSize), with: nil, afterDelay: 0.1)
            }
        }
    }

    // MARK: - life
    deinit {
        observation?.invalidate()
    }
    
    // MARK: - target
    @objc func textDidChange(_ sender: UITextField) {
        print("\(NSStringFromClass(Self.self)) \(#function) text: \(sender.text ?? "")")
        var text = sender.text ?? ""
        if text.contains("⌘") {
            text = text.replacingOccurrences(of: "⌘", with: "")
        }
        model.setAnswer(text: sender.text ?? "")
        textView.attributedText = model.resultAttributed
    }
    
    @objc func responseSize() {
        contentSizeWillChange?()
        
        textViewHeight.constant = textView.contentSize.height
        
        contentSizeDidChange?()
    }
}

// MARK: - UITextViewDelegate
extension QueContentFillBlankCell: UITextViewDelegate {
 
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("\(NSStringFromClass(Self.self)) \(#function) url: \(URL.absoluteString)")
        if URL.absoluteString.hasPrefix(snFillBlankURLPrefix) {
            if let str = URL.absoluteString.components(separatedBy: snSeparate).last, let index = Int(str) {
                model.focunsIndex = index
                textView.attributedText = model.resultAttributed
                
                textField.text = model.getAnswer(index: index)
                
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
        if var answer = textField.text {
            answer = answer.replacingOccurrences(of: "⌘", with: "")
            model.setAnswer(text: answer)
        }
        model.updateScore()
    }
}

// MARK: - QueContentModelDelegate
extension QueContentFillBlankCell: QueContentModelDelegate {
    
    func contentDidChange(model: any QueContentModel) {
        textView.attributedText = self.model.resultAttributed
    }
}

