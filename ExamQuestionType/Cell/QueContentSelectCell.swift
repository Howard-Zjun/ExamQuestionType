//
//  QueContentSelectCell.swift
//  ExamQuestionType
//
//  Created by ios on 2024/6/20.
//

import UIKit

class QueContentSelectCell: UITableViewCell {

    var observation: NSKeyValueObservation?

    var contentModel: QueContentSelectModel! {
        didSet {
            textView.attributedText = contentModel.resultAttributed
        }
    }
    
    var contentSizeDidChange: ((UITextView) -> Void)?

    var actionDidChange: ((Int) -> Void)?
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.font = .systemFont(ofSize: 18)
            textView.delegate = self
            textView.isEditable = false
            textView.linkTextAttributes = .init()
            
            observation = textView.observe(\.contentSize, options: .new) { [weak self] textView, change in
                print("\(NSStringFromClass(Self.self)) \(#function): 变化高度\(textView.contentSize)")
                self?.heightConstraint.constant = textView.contentSize.height
                
                self?.contentSizeDidChange?(textView)
            }
        }
    }
    
    deinit {
        observation?.invalidate()
    }
}

// MARK: - UITextViewDelegate
extension QueContentSelectCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("\(NSStringFromClass(SelectFillBlankCell.self)) \(#function) url: \(URL.absoluteString)")
        if URL.absoluteString.hasPrefix(fillBlankURLPrefix) {
            if let postionString = URL.absoluteString.components(separatedBy: ":").last{
                self.actionDidChange?(Int(postionString) ?? 0)
            }
        }
        return false
    }
}
