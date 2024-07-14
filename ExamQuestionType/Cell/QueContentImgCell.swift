//
//  QueContentImgCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/12.
//

import UIKit
import SnapKit

class QueContentImgCell: UITableViewCell {
    
    var model: QueContentImgModel! {
        didSet {
            imgView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
            }
            
            if let width = model.imageModel.width, let height = model.imageModel.height {
                imgView.sd_setImage(with: model.imageModel.src)
                imgFit(width: width, height: height)
            } else {
                let tempModel = model
                imgView.sd_setImage(with: model.imageModel.src) { [weak self] img, _, _, _ in
                    guard tempModel == self?.model else { return }
                    if let img = img {
                        self?.imgFit(width: img.size.width, height: img.size.height)
                    } else {
                        self?.imgFit(width: 100, height: 100)
                    }
                }
            }
        }
    }
    
    // MARK: - view
    lazy var imgView: UIImageView = {
        let imgView = UIImageView(frame: .init(x: 20, y: 0, width: 100, height: 100))
        return imgView
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imgFit(width: CGFloat, height: CGFloat) {
        var width = width
        var height = height
        let p = model.contentInset.left + model.contentInset.right
        if width > kScreenWidth - p {
            height = (kScreenWidth - p) / width * height
            width = kScreenWidth - p
        }
        imgView.snp.updateConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
    }
}
