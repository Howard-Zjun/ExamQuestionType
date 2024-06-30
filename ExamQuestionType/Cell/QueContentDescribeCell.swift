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
            if textViewTop != nil {
                textViewTop.constant = model.contentInset.top
            }
            if textView != nil {
                textView.attributedText = model.attr
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
            textView.textColor = .init(hex: 0x333333)
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
        textViewTop.constant = model.contentInset.top
        textView.attributedText = model.attr
    }
    
    deinit {
        observation?.invalidate()
    }
}

// MARK: - UITextViewDelegate
extension QueContentDescribeCell: UITextViewDelegate {
    
}
