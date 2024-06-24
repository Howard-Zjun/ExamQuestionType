//
//  QueContentImgCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit

class QueContentImgCell: UITableViewCell {
    
    var imgHeight: CGFloat = 100
    
    var imgWidth: CGFloat = 100
    
    var model: QueContentImgModel! {
        didSet {
            imgView.sd_setImage(with: model.imageModel.src)
            if var tempWidth = model.imageModel.width, var tempHeight = model.imageModel.height {
                if tempWidth > kScreenWidth - 40 {
                    tempHeight = (kScreenWidth - 40) / tempWidth * tempHeight
                    tempWidth = kScreenWidth - 40
                }
                imgWidth = tempWidth
                imgHeight = tempHeight
            }
            imgView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.width.equalTo(imgWidth)
                make.height.equalTo(imgHeight)
            }
        }
    }
    
    // MARK: - view
    lazy var imgView: UIImageView = {
        let imgView = UIImageView(frame: .init(x: 20, y: 0, width: imgWidth, height: imgHeight))
        return imgView
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview()
            make.width.equalTo(imgWidth)
            make.height.equalTo(imgHeight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
