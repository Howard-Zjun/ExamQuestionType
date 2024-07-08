//
//  QueContentSelectContentCell.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/07/09.
//

import UIKit

class QueContentSelectContentCell: UITableViewCell {

    var model: QueContentSelectContentModel! {
        didSet {
            model.delegate = self
            textView.attributedText = model.resultAttributed
            textView.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
                make.height.equalTo(textView.contentSize.height)
            }
        }
    }
    
    // MARK: - view
    lazy var textView: UITextView = {
        let textView = UITextView(frame: .init(x: 0, y: 0, width: contentView.kwidth, height: 30))
        textView.isEditable = false
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        textView.font = .systemFont(ofSize: 18)
        return textView
    }()
    
    // MARK: - life
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
            make.height.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - QueContentModelDelegate
extension QueContentSelectContentCell: QueContentModelDelegate {
    
    func contentDidChange(model: any QueContentModel) {
        textView.attributedText = self.model.resultAttributed
    }
}
