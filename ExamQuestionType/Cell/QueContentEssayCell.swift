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
    
    var textDidChange: ((String) -> Void)?
    
    var actionDidChange: ((IndexPath) -> Void)?
    
    var observation: NSKeyValueObservation?
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var textViewLeft: NSLayoutConstraint!
    
    @IBOutlet weak var textViewRight: NSLayoutConstraint!
    
    var indexPath: IndexPath!
    
    var model: QueContentEssayModel! {
        didSet {
            textView.isSelectable = !model.isResult
            textView.isUserInteractionEnabled = !model.isResult
            
            textViewTop.constant = model.contentInset.top
            textViewBottom.constant = model.contentInset.bottom
            textViewLeft.constant = model.contentInset.left
            textViewRight.constant = model.contentInset.right
            
            textView.text = model.getAnswer()
            if let estimatedHeight = model.estimatedHeight {
                textViewHeight.constant = estimatedHeight
            } else {
                textViewHeight.constant = textView.contentSize.height
            }
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
            model.estimatedHeight = 30
            textViewHeight.constant = 30
        } else {
            model.estimatedHeight = textView.contentSize.height
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
        textDidChange?(textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        actionDidChange?(indexPath)
    }
}
