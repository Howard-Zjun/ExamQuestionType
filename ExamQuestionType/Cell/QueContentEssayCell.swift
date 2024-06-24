//
//  QueContentEssayCell.swift
//  ExamQuestionType
//
//  Created by ios on 2024/6/19.
//

import UIKit

class QueContentEssayCell: UITableViewCell {

    // 用来通知外部 tableView 做更新
    var contentSizeDidChange: ((UITextView) -> Void)?
    
    var textDidChange: ((UITextView, String) -> Void)?
    
    var observation: NSKeyValueObservation?
    
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.brown.cgColor
            observation = textView.observe(\.contentSize) { [weak self] textView, change in
                print(textView.contentSize)
                if textView.contentSize.height < 30 {
                    self?.heightConstraints.constant = 30
                } else {
                    self?.heightConstraints.constant = textView.contentSize.height
                }
                self?.contentSizeDidChange?(textView)
            }
            textView.delegate = self
        }
    }

    deinit {
        observation?.invalidate()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(content: String) {
        textView.text = content
    }
}

// MARK: - UITextViewDelegate
extension QueContentEssayCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        textDidChange?(textView, textView.text)
    }
}
