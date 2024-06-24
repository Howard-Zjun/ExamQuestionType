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
        }
    }
    
    // MARK: - view
    lazy var gradientImgV: UIImageView = {
        let gradientImgV = UIImageView(frame: .init(x: 14, y: 14, width: contentView.kwidth - 28, height: 32))
        gradientImgV.layer.cornerRadius = 16
        gradientImgV.layer.masksToBounds = true
        gradientImgV.contentMode = .scaleToFill
        gradientImgV.image = backgroundGradient([UIColor(hex: "D8ECFF"),UIColor(hex: "FFFFFF")])
        return gradientImgV
    }()
    
    lazy var titleLab: UILabel = {
        let titleLab = UILabel(frame: .init(x: 18, y: 5, width: contentView.kwidth - 36, height: 22))
        titleLab.font = .systemFont(ofSize: 16, weight: .bold)
        titleLab.textColor = .init(hex: "333333")
        titleLab.numberOfLines = 0
        titleLab.contentMode = .left
        titleLab.lineBreakMode = .byTruncatingTail
        return titleLab
    }()
    
    lazy var qsTitleLab: UILabel = {
        let qsTitleLab = UILabel(frame: .init(x: 17, y: gradientImgV.kmaxY + 12, width: contentView.kwidth - 34, height: 0))
        qsTitleLab.font = UIFont(name: "Helvetica", size: 17)
        qsTitleLab.textColor = .init(hex: "333333")
        qsTitleLab.numberOfLines = 0
        qsTitleLab.contentMode = .left
        qsTitleLab.lineBreakMode = .byTruncatingTail
        return qsTitleLab
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(gradientImgV)
        gradientImgV.addSubview(titleLab)
        contentView.addSubview(qsTitleLab)
        gradientImgV.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(14)
            make.bottom.equalTo(titleLab.snp.bottom)
        }
        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(18)
            make.top.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(22)
        }
        qsTitleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(17)
            make.top.equalTo(gradientImgV.snp.bottom).offset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func backgroundGradient(_ colors: [UIColor]) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = .init(x: 0, y: 0.5)
        gradientLayer.endPoint = .init(x: 1, y: 0.5)
        gradientLayer.colors = colors
        gradientLayer.frame = .init(x: 0, y: 0, width: 100, height: 100)
        
        UIGraphicsBeginImageContext(.init(width: 100, height: 100))
        gradientLayer.render(in: UIGraphicsGetCurrentContext())
        let ret = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return ret
    }
}

