//
//  QueContentDescribeCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit

class QueContentDescribeCell: UITableViewCell {
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var textViewLeft: NSLayoutConstraint!
    
    @IBOutlet weak var textViewRight: NSLayoutConstraint!
    
    var model: QueContentDescribeModel! {
        didSet {
            textViewTop.constant = model.contentInset.top
            textViewBottom.constant = model.contentInset.bottom
            textViewLeft.constant = model.contentInset.left
            textViewRight.constant = model.contentInset.right
            
            textView.attributedText = model.handleContentAttr
            if let estimatedHeight = model.estimatedHeight {
                textViewHeight.constant = estimatedHeight
            } else {
                textViewHeight.constant = textView.contentSize.height
            }
        }
    }
    
    var contentSizeWillChange: (() -> Void)?
    
    var contentSizeDidChange: (() -> Void)?
    
    var observation: NSKeyValueObservation?

    // MARK: - view
    @IBOutlet weak var textView: DisRangeAbleTextView! {
        didSet {
            textView.font = .systemFont(ofSize: 17)
            textView.textColor = .init(hex: 0x333333)
            textView.isEditable = false
            textView.isSelectable = false
            observation = textView.observe(\.contentSize) { [weak self] textView, change in
                guard let self = self else { return }
                print("\(NSStringFromClass(Self.self)) \(#function): 变化高度\(textView.contentSize)")

                NSObject.cancelPreviousPerformRequests(withTarget: self)
                perform(#selector(responseSize), with: nil, afterDelay: 0.1)
            }
        }
    }
    
    // MARK: - init
    deinit {
        observation?.invalidate()
    }
    
    // MARK: - target
    @objc func responseSize() {        
        model.estimatedHeight = textView.contentSize.height

        contentSizeWillChange?()
        
        textViewHeight.constant = textView.contentSize.height
        
        contentSizeDidChange?()
    }
}
