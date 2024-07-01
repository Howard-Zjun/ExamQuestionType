//
//  QueContentTitleCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit

class QueContentTitleCell: UITableViewCell {
    
    var model: QueContentTitleModel! {
        didSet {
            titleLab.text = model.title
            qsTitleLab.text = model.qstTitle
            titleLab.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
            }
            qsTitleLab.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
            }
        }
    }
    
    // MARK: - view
    lazy var titleLab: UILabel = {
        let titleLab = UILabel(frame: .init(x: 18, y: 5, width: contentView.kwidth - 36, height: 22))
        titleLab.font = .systemFont(ofSize: 16, weight: .bold)
        titleLab.textColor = .init(hex: 0x333333)
        titleLab.numberOfLines = 0
        titleLab.contentMode = .left
        titleLab.lineBreakMode = .byTruncatingTail
        return titleLab
    }()
    
    lazy var qsTitleLab: UILabel = {
        let qsTitleLab = UILabel(frame: .init(x: 17, y: titleLab.kmaxY + 12, width: contentView.kwidth - 34, height: 0))
        qsTitleLab.font = UIFont(name: "Helvetica", size: 17)
        qsTitleLab.textColor = .init(hex: 0x333333)
        qsTitleLab.numberOfLines = 0
        qsTitleLab.contentMode = .left
        qsTitleLab.lineBreakMode = .byTruncatingTail
        return qsTitleLab
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLab)
        contentView.addSubview(qsTitleLab)
        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(18)
            make.top.equalToSuperview().inset(0)
        }
        qsTitleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(18)
            make.top.equalTo(titleLab.snp.bottom).offset(12)
            make.bottom.equalToSuperview().inset(0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

