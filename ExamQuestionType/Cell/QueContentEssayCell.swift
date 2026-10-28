//
//  QueContentEssayCell.swift
//  ExamQuestionType
//
//  Created by ios on 2024/6/19.
//

import UIKit
import SnapKit

class QueContentEssayCell: UITableViewCell {

    // 内容变化，通知外部调整单元高度
    var contentSizeWillChange: (() -> Void)?
    var contentSizeDidChange: (() -> Void)?
    
    var textDidChange: ((String) -> Void)?
    
    var actionDidChange: ((IndexPath) -> Void)?
    
    private var observation: NSKeyValueObservation?
    
    var indexPath: IndexPath!
    
    private var initHeight: CGFloat { 60 }
    
    var model: QueContentEssayModel! {
        didSet {
            textView.isSelectable = !model.isResult
            textView.isUserInteractionEnabled = !model.isResult
            textView.text = model.getAnswer()
            textView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
                make.leading.equalToSuperview().inset(model.contentInset.left)
                make.trailing.equalToSuperview().inset(model.contentInset.right)
                make.height.equalTo(model.estimatedHeight ?? model.estimateContentHeight)
            }
        }
    }
    
    // MARK: - view
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.font = .systemFont(ofSize: 14)
        textView.autocapitalizationType = .sentences
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.brown.cgColor
        textView.delegate = self
        observation = textView.observe(\.contentSize) { [weak self] textView, change in
            guard let self = self else { return }
            print("\(NSStringFromClass(Self.self)) \(#function) size: \(textView.contentSize)")

            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(responseSize), with: nil, afterDelay: 0.1)
        }
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
            make.height.equalTo(initHeight)
        }
    }

    // MARK: - life
    deinit {
        observation?.invalidate()
    }
    
    // MARK: - target
    @objc func responseSize() {
        guard let model = model else { return }
        contentSizeWillChange?()
        
        let height = max(30, textView.contentSize.height)
        model.estimatedHeight = height
        textView.snp.updateConstraints { make in
            make.height.equalTo(height)
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
