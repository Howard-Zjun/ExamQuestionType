import UIKit

class QueContentSelectCell: UITableViewCell {

    var observation: NSKeyValueObservation?

    var model: QueContentSelectModel! {
        didSet {
            model.delegate = self
            textViewTop.constant = model.contentInset.top
            textViewBottom.constant = model.contentInset.bottom
            textView.attributedText = model.resultAttributed
        }
    }
    
    var contentSizeBeginChange: (() -> Void)?
    
    var contentSizeDidChange: (() -> Void)?

    var actionDidChange: ((Int) -> Void)?
    
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var textViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
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
        contentSizeBeginChange?()
        
        textViewBottom.constant = textView.contentSize.height
        
        contentSizeDidChange?()
    }
}

// MARK: - UITextViewDelegate
extension QueContentSelectCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        print("\(NSStringFromClass(Self.self)) \(#function) url: \(URL.absoluteString)")
        if URL.absoluteString.hasPrefix(snFillBlankURLPrefix) {
            if let postionString = URL.absoluteString.components(separatedBy: snSeparate).last{
                self.actionDidChange?(Int(postionString) ?? 0)
            }
        }
        return false
    }
}

// MARK: - QueContentModelDelegate
extension QueContentSelectCell: QueContentModelDelegate {
    
    func contentDidChange(model: any QueContentModel) {
        textView.attributedText = self.model.resultAttributed
    }
}
