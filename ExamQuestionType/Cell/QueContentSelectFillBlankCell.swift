import UIKit

class QueContentSelectFillBlankCell: UITableViewCell {
    
    var contentSizeBeginChange: (() -> Void)?
    
    var contentSizeDidChange: (() -> Void)?

    var actionDidChange: ((Int) -> Void)?
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var textViewLeft: NSLayoutConstraint!
    
    @IBOutlet weak var textViewRight: NSLayoutConstraint!
    
    var observation: NSKeyValueObservation?

    var model: QueContentSelectFillBlankModel! {
        didSet {
            model.delegate = self
            
            textViewTop.constant = model.contentInset.top
            textViewBottom.constant = model.contentInset.bottom
            textViewLeft.constant = model.contentInset.left
            textViewRight.constant = model.contentInset.right
            
            textView.attributedText = model.resultAttributed
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
    
    deinit {
        observation?.invalidate()
    }
    
    // MARK: - target
    @objc func responseSize() {
        model.estimatedHeight = textView.contentSize.height
        
        if textViewHeight.constant != textView.contentSize.height {
            contentSizeBeginChange?()
            
            textViewHeight.constant = textView.contentSize.height
            
            contentSizeDidChange?()
        }
    }
}

// MARK: - UITextViewDelegate
extension QueContentSelectFillBlankCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("\(NSStringFromClass(Self.self)) \(#function) url: \(URL.absoluteString)")
        if URL.absoluteString.hasPrefix(snFillBlankURLPrefix) {
            if let str = URL.absoluteString.components(separatedBy: snSeparate).last, let index = Int(str) {
                
                let answer: Int? = model.getAnswer(index: index)
                print("\(NSStringFromClass(Self.self)) \(#function) index: \(index), text: \(String(describing: answer))")
                
                self.actionDidChange?(index)
            }
        }
        return false
    }
}

// MARK: - QueContentModelDelegate
extension QueContentSelectFillBlankCell: QueContentModelDelegate {
    
    func contentDidChange(model: any QueContentModel) {
        textView.attributedText = self.model.resultAttributed
    }
}
