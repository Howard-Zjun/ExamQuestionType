//
//  QueContentDescribeCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit

class QueContentDescribeCell: UITableViewCell {

    @IBOutlet weak var textHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    
    var model: QueContentDescribeModel! {
        didSet {
            textViewTop.constant = model.contentInset.top
            if let content = model.handleContent {
                textView.text = content
            } else if let contentAttr = model.handleContentAttr {
                textView.attributedText = contentAttr
            }
        }
    }
    
    var contentSizeDidChange: ((UITextView) -> Void)?
    
    var observation: NSKeyValueObservation?

    // MARK: - view
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            textView.font = .systemFont(ofSize: 17)
            textView.textColor = .init(hex: "333333")
            textView.isEditable = false
            observation = textView.observe(\.contentSize) { [weak self] textView, change in
                self?.textHeight.constant = textView.contentSize.height
                self?.contentSizeDidChange?(textView)
            }
        }
    }
    
    // MARK: - init
    override func awakeFromNib() {
        super.awakeFromNib()
        textHeight.constant = textView.contentSize.height
    }
    
    deinit {
        observation?.invalidate()
    }
}

// MARK: - UITextViewDelegate
extension QueContentDescribeCell: UITextViewDelegate {
    
}
