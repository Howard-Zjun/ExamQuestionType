//
//  QueContentVideoCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/18.
//

import UIKit

class QueContentVideoCell: UITableViewCell {

    var swidth: CGFloat {
        UIScreen.main.bounds.width - 40
    }
    
    var sheight: CGFloat {
        swidth * 10 / 16.0
    }
    
    var model: QueContentVideoModel! {
        didSet {
            videoView.initPlayer(url: model.videoRes)
            videoView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
            }
        }
    }
    
    // MARK: - view
    lazy var videoView: VideoPlayView = {
        let videoView = VideoPlayView(frame: .init(x: 20, y: 0, width: swidth, height: sheight))
        return videoView
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(videoView)
        videoView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
            make.height.equalTo(sheight)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
