import UIKit
import SnapKit

class QueContentSelectFillBlankCell: UITableViewCell {
    
    var contentSizeBeginChange: (() -> Void)?
    var contentSizeDidChange: (() -> Void)?

    var actionDidChange: ((Int) -> Void)?
    
    private var textViewHeight: CGFloat = 150
    
    private var observation: NSKeyValueObservation?

    var model: QueContentSelectFillBlankModel! {
        didSet {
            model.delegate = self
            
            textView.attributedText = model.resultAttributed
            textViewHeight = model.estimatedHeight ?? textView.contentSize.height
            textView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
                make.leading.equalToSuperview().inset(model.contentInset.left)
                make.trailing.equalToSuperview().inset(model.contentInset.right)
                make.height.equalTo(textViewHeight)
            }
        }
    }
    
    // MARK: - view
    private lazy var textView: DisRangeAbleTextView = {
        let textView = DisRangeAbleTextView()
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.autocapitalizationType = .sentences
        textView.font = .systemFont(ofSize: 18)
        textView.delegate = self
        textView.isEditable = false
        textView.linkTextAttributes = .init()
        return textView
    }()

    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        contentView.clipsToBounds = true
        contentView.contentMode = .center
        contentView.isMultipleTouchEnabled = true
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(textViewHeight)
        }
        observation = textView.observe(\.contentSize, options: .new) { [weak self] textView, change in
            guard let self = self else { return }
            print("\(NSStringFromClass(Self.self)) \(#function): 变化高度\(textView.contentSize)")

            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(responseSize), with: nil, afterDelay: 0.1)
        }
    }
    
    deinit {
        observation?.invalidate()
    }
    
    // MARK: - target
    @objc func responseSize() {
        guard let model = model else { return }
        model.estimatedHeight = textView.contentSize.height
        
        if textViewHeight != textView.contentSize.height {
            contentSizeBeginChange?()
            
            textViewHeight = textView.contentSize.height
            textView.snp.updateConstraints { make in
                make.height.equalTo(textViewHeight)
            }
            
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
