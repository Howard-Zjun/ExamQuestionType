//
//  QueContentVoiceCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit

class QueContentVoiceCell: UITableViewCell {
    
    var model: QueContentVoiceModel! {
        didSet {
            baseView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
            }
        }
    }
    
    // MARK: - view
    lazy var baseView: UIView = {
        let baseView = UIView(frame: contentView.bounds)
        return baseView
    }()
    
    lazy var playBtn: UIButton = {
        let playBtn = UIButton(frame: .init(x: 17, y: (contentView.kheight - 40) * 0.5, width: 40, height: 40))
        playBtn.setImage(.init(named: "record_start"), for: .normal)
        playBtn.setImage(.init(named: "record_stop"), for: .selected)
        playBtn.addTarget(self, action: #selector(touchPlayBtn(_:)), for: .touchUpInside)
        return playBtn
    }()
    
    lazy var curTimeLab: UILabel = {
        let curTimeLab = UILabel(frame: .init(x: playBtn.kmaxX + 10, y: (contentView.kheight - 18) * 0.5, width: 42, height: 18))
        curTimeLab.font = .systemFont(ofSize: 15)
        curTimeLab.textColor = .init(hex: 0xCCCCCC)
        curTimeLab.text = "00:00"
        return curTimeLab
    }()
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = .init(x: curTimeLab.kmaxX + 8, y: (contentView.kheight - 4) * 0.5, width: timeLab.kminX - 8 - curTimeLab.kmaxX - 8, height: 4)
        return progressView
    }()
    
    lazy var timeLab: UILabel = {
        let timeLab = UILabel(frame: .init(x: contentView.kwidth - 150 - 42, y: (contentView.kheight - 18) * 0.5, width: 42, height: 18))
        timeLab.font = .systemFont(ofSize: 15)
        timeLab.textColor = .init(hex: 0xCCCCCC)
        timeLab.text = "00:00"
        return timeLab
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(baseView)
        baseView.addSubview(playBtn)
        baseView.addSubview(curTimeLab)
        baseView.addSubview(progressView)
        baseView.addSubview(timeLab)
        
        baseView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
        }
        playBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(17)
            make.size.equalTo(40)
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        curTimeLab.snp.makeConstraints { make in
            make.left.equalTo(playBtn.snp.right).offset(10)
            make.size.equalTo(CGSize(width: 42, height: 18))
            make.centerY.equalToSuperview()
        }
        timeLab.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(150)
            make.size.equalTo(CGSize(width: 42, height: 18))
            make.centerY.equalToSuperview()
        }
        progressView.snp.makeConstraints { make in
            make.left.equalTo(curTimeLab.snp.right).offset(8)
            make.right.equalTo(timeLab.snp.left).offset(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - target
    @objc func touchPlayBtn(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            
        } else {
            
        }
    }
    
    func playQsAudio(url:String){
//        AVPlayerManger.shared.playURL(url: URL(string: url),finishBlock: {[weak self]  in
//            guard let self = self else {return}
//            self.curTimeLab.text =  "00:00"
//            self.progressView.progress =  0.0
//            self.playBtn.initButton()
//        },progress:  {[weak self] cur in
//            guard let self = self else {return}
//            curTimeLab.text = DateUtil.parseTime(timeInMillis: cur * 1000)
//            progressView.progress = Float(cur) / Float(model.qsTimeTotal)
//        })
    }
}

