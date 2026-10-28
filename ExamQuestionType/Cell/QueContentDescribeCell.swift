//
//  QueContentDescribeCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit
import SnapKit

class QueContentDescribeCell: UITableViewCell {

    var model: QueContentDescribeModel! {
        didSet {
            contentLabel.attributedText = model.handleContentAttr
            contentLabel.font = model.font
            contentLabel.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
                make.leading.equalToSuperview().inset(model.contentInset.left)
                make.trailing.equalToSuperview().inset(model.contentInset.right)
                make.height.equalTo(model.estimatedHeight ?? model.estimateContentHeight)
            }
        }
    }

    // MARK: - view
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemBackground
        label.font = .systemFont(ofSize: 17)
        label.textColor = .init(hex: 0x333333)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
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
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
            make.leading.equalToSuperview().inset(0)
            make.trailing.equalToSuperview().inset(0)
            make.height.equalTo(100)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        model?.estimatedHeight = contentLabel.bounds.height
    }
}
