//
//  QueContentFillBlankCell.swift
//  ExamQuestionType
//
//  Created by ios on 2024/6/19.
//

import UIKit
import SnapKit

/// 不能框选的 textview
class DisRangeAbleTextView: UITextView {
    
    // 取消框选
    override var canBecomeFirstResponder: Bool {
        false
    }
}

class QueContentFillBlankCell: UITableViewCell {

    var observation: NSKeyValueObservation?

    // 内容变化，通知外部调整单元高度
    var contentSizeWillChange: (() -> Void)?
    var contentSizeDidChange: (() -> Void)?

    private var initHeight: CGFloat { 150 }
    
    var model: QueContentFillBlankModel! {
        didSet {
            model.delegate = self

            textView.isSelectable = !model.isResult
            textView.isUserInteractionEnabled = !model.isResult
            
            textView.attributedText = model.resultAttributed
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
    // 用于点击 textView 的填空时，聚焦 textField 来编辑
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 14)
        textField.minimumFontSize = 17
        textField.setContentHuggingPriority(.init(248), for: .horizontal)
        textField.returnKeyType = .done
        textField.delegate = self
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var textView: DisRangeAbleTextView = {
        let textView = DisRangeAbleTextView()
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.autocapitalizationType = .sentences
        textView.font = .systemFont(ofSize: 18)
        textView.delegate = self
        textView.isEditable = false
        textView.linkTextAttributes = .init()
        observation = textView.observe(\.contentSize, options: .new) { [weak self] textView, change in
            guard let self = self else { return }
            print("\(NSStringFromClass(Self.self)) \(#function): 变化高度\(textView.contentSize)")

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
        contentView.addSubview(textField)
        contentView.addSubview(textView)
        textField.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(111)
            make.top.equalToSuperview().offset(5)
            make.width.equalTo(97)
            make.height.equalTo(34)
        }
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
    @objc func textDidChange(_ sender: UITextField) {
        print("\(NSStringFromClass(Self.self)) \(#function) text: \(sender.text ?? "")")
        var text = sender.text ?? ""
        if text.contains("⌘") {
            text = text.replacingOccurrences(of: "⌘", with: "")
        }
        model.setAnswer(text: sender.text ?? "")
    }
    
    @objc func responseSize() {
        guard let model = model else { return }
        if model.estimatedHeight != textView.contentSize.height {
            model.estimatedHeight = textView.contentSize.height
                
            contentSizeWillChange?()
            
            textView.snp.updateConstraints { make in
                make.height.equalTo(textView.contentSize.height)
            }
            
            contentSizeDidChange?()
        }
    }
}

// MARK: - UITextViewDelegate
extension QueContentFillBlankCell: UITextViewDelegate {
 
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString.hasPrefix(snFillBlankURLPrefix) {
            if let str = URL.absoluteString.components(separatedBy: snSeparate).last, let index = Int(str) {
                model.focunsIndex = index
                
                textField.text = model.getAnswer(index: index)
                
                print("\(NSStringFromClass(Self.self)) \(#function) index: \(index), text: \(textField.text ?? "")")
                
                textField.becomeFirstResponder()
            }
        }
        return false
    }
}

// MARK: - UITextFieldDelegate
extension QueContentFillBlankCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.endEditing(true)
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if var answer = textField.text {
            answer = answer.replacingOccurrences(of: "⌘", with: "")
            model.setAnswer(text: answer)
        }
    }
}

// MARK: - QueContentModelDelegate
extension QueContentFillBlankCell: QueContentModelDelegate {
    
    func contentDidChange(model: any QueContentModel) {
        textView.attributedText = self.model.resultAttributed
    }
}

