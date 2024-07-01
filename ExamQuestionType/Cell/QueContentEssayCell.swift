//
//  QueContentEssayCell.swift
//  ExamQuestionType
//
//  Created by ios on 2024/6/19.
//

import UIKit

class QueContentEssayCell: UITableViewCell {

    var contentSizeWillChange: (() -> Void)?
    // 用来通知外部 tableView 做更新
    var contentSizeDidChange: (() -> Void)?
    
    var textDidChange: ((UITextView, String) -> Void)?
    
    var observation: NSKeyValueObservation?
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    var model: QueContentEssayModel! {
        didSet {
            textViewTop.constant = model.contentInset.top
            textViewBottom.constant = model.contentInset.bottom
            textView.text = model.getAnswer()
        }
    }
    
    // MARK: - view
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.brown.cgColor
            observation = textView.observe(\.contentSize) { [weak self] textView, change in
                guard let self = self else { return }
                print("\(NSStringFromClass(Self.self)) \(#function) size: \(textView.contentSize)")
                
                NSObject.cancelPreviousPerformRequests(withTarget: self)
                perform(#selector(responseSize), with: nil, afterDelay: 0.1)
            }
            textView.delegate = self
        }
    }

    // MARK: - life
    deinit {
        observation?.invalidate()
    }
    
    // MARK: - target
    @objc func responseSize() {
        contentSizeWillChange?()
        
        if textView.contentSize.height < 30 {
            textViewHeight.constant = 30
        } else {
            textViewHeight.constant = textView.contentSize.height
        }
        
        contentSizeDidChange?()
    }
    
    func set(content: String) {
        textView.text = content
        model.setAnswer(text: content)
    }
}

// MARK: - UITextViewDelegate
extension QueContentEssayCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textDidChange?(textView, textView.text)
    }
}
