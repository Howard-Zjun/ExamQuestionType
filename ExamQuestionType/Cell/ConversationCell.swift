//
//  ConversationCell.swift
//  ListenSpeak
//
//  Created by ios on 2023/3/13.
//

import UIKit
import KDCircularProgress
import SwiftEventBus
class ConversationCell: UITableViewCell {
    
    @IBOutlet weak var playView: UIView!
    
    @IBOutlet weak var playViewHeight: NSLayoutConstraint!
    // 题目语音总长度
    @IBOutlet weak var qsTimeLabel: UILabel!
    // 当前播放的 进度
    @IBOutlet weak var qsCurTimeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    // 播放按钮
    @IBOutlet weak var playBtn: PlayButton!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordPro: KDCircularProgress!
    @IBOutlet weak var recordLabel: UILabel!
    
    @IBOutlet weak var meView: UIView!
    @IBOutlet weak var mePro: KDCircularProgress!
    @IBOutlet weak var meLabel: UILabel!

    
    var qsTimeTotal = 0
    var paperId:Int = 0
    var savePath:String?
    var qstDetailLevel2:QstDetailLevel2?{
        didSet{
           
            if QSFunc.isGeneral(qstDetailLevel2: qstDetailLevel2){
                playView.isHidden = true
                playViewHeight.constant = 0
            }else{
//                /* 题干语音 111 */
//                let qsDescri =  qstDetailLevel2?.qst_detail?.getQuestionDescriptionVoice()
//                /* 听力录音 112*/
//                let qsListen =  qstDetailLevel2?.qst_detail?.getListenVoice()
//                if qsDescri != nil{
//                    playView.isHidden = false
//                    playViewHeight.constant = 40
//                    qsTimeTotal =  QSFunc.getAudioDuration(url: qsDescri)
//                    qsTimeLabel.text = DateUtil.parseTime(timeInMillis: qsTimeTotal * 1000)
//                }
//                else if qsListen != nil{
//                    playView.isHidden = false
//                    playViewHeight.constant = 40
//                    qsTimeTotal = QSFunc.getAudioDuration(url: qsListen)
//                    qsTimeLabel.text = DateUtil.parseTime(timeInMillis: qsTimeTotal * 1000)
//                }
//                else{
                // 统一 到 UIQuestionHead 处理
                    playView.isHidden = true
                    playViewHeight.constant = 0
//                }
            }
            //本地录音
//            savePath = qstDetailLevel2?.qst_detail?.recordVoice
            //我的录音
            if let userAnswers = qstDetailLevel2?.qst_detail?.userAnswer,!userAnswers.isEmpty,
               let userAnswer = userAnswers.first,!userAnswer.isEmpty{
                meView.isHidden = false
            }else{
                meView.isHidden = true
            }
            
            
        }
    }
    deinit {
        SwiftEventBus.unregister(self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //停止播放语音
        SwiftEventBus.onMainThread(self, name:EvenBusName.StopAudio) {[weak self]  notify in
            guard let self = self else{return}
            mePro.stopAnimation()
        }
        SwiftEventBus.onMainThread(self, name:EvenBusName.StopVoice) {[weak self]  notify in
            guard let self = self else{return}
            mePro.stopAnimation()
        }
        //停止播放语音
        SwiftEventBus.onMainThread(self, name:EvenBusName.StopRecordAnim) {[weak self]  notify in
            guard let self = self else{return}
            recordPro.stopAnimation()
            recordLabel.text = "开始录音"
            recordButton.isSelected = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    /*
     播放题目
     */
    @IBAction func playQs(_ sender: Any) {
        /* 题干语音 111 */
        let qsDescri =  qstDetailLevel2?.qst_detail?.getQuestionDescriptionVoice()
        /* 听力录音 112*/
        let qsListen =  qstDetailLevel2?.qst_detail?.getListenVoice()
        if let url = qsDescri{
            playQsAudio(url: url)
        }
        else if let url = qsListen{
            playQsAudio(url: url)
        }
        playBtn.playButton()
    }
    
    //录音
    @IBAction func record(_ sender: UIButton) {
        //防抖处理
        if !SingEngine.shared.isRecording(){
            sender.isUserInteractionEnabled = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sender.isUserInteractionEnabled = true
        }
        
        if SingEngine.shared.isRecording(){
            //点击的是同一个
            if let _ = savePath{
                SingEngine.shared.stopEvaluating()
                recordPro.stopAnimation()
                recordButton.isSelected = false
                meView.isHidden = false
                recordLabel.text = "重新录音"
            }else{
                SingEngine.shared.cancelEvaluating()
                SwiftEventBus.post(EvenBusName.StopRecordAnim)
            }

        }else{
           
            guard let answerTime = qstDetailLevel2?.qst_detail?.getAnswerTime() else{return}
            log.debug("duration = \(answerTime)")
            guard let qstId = qstDetailLevel2?.qid else{return}
            //最长5分钟,限制一下
            let duration = min(answerTime, DslEngine.DslEngineMaxTime)
            
            savePath = getTestPaperDataPaperRecordResPath(paperId: paperId, qstId: qstId, isExam: false)
            SingEngine.shared.startReview(evaluationType: qstDetailLevel2?.qst_detail?.evaluationType ?? 0,
                                          correctAnswerList: qstDetailLevel2?.qst_detail?.correctAnswer ?? [],
                                          correctAnswerExtraList: qstDetailLevel2?.qst_detail?.correctAnswerExtra,
                                          unkey: qstDetailLevel2?.qst_detail?.unkey,
                                          rank: Float(qstDetailLevel2?.score ?? 0),
                                          storeWavPath:savePath ?? "",
                                          delegate: self) {[weak self] count in
                guard let self = self else { return }
                recordLabel.text = "正在录音" + DateUtil.parseTime(timeInSec: duration - count)
            }
            recordButton.isSelected = true
            meView.isHidden = true // 录音时隐藏我的录音按钮
            recordPro.animate(fromAngle: 360,
                              toAngle: 0,
                              duration: TimeInterval(duration)) {[weak self] completed in
                guard let self = self else{return}
                if completed {
                    self.meView.isHidden = false
                    SingEngine.shared.stopEvaluating()
                }
            }
        }
    }
    //播放我的录音
    @IBAction func play(_ sender: Any) {
//        guard let url = savePath else{return}
        guard let url =  qstDetailLevel2?.qst_detail?.userAnswer.first else{return}
        
        if AVPlayerManger.shared.isPlaying(url: URL(string: url)){
            AVPlayerManger.shared.pause()
            mePro.stopAnimation()
        }else{

            playMeRecordAudio(url: url)
        }
    }
    
    func handleSpeakResult(result:[String : Any]?){
        guard let result = result else { return  }
        let resultScore = RecordResultUtil.getOverAll(result: result)
        let recordResult = jsonToString(json: result as NSDictionary)
        
        var score:Double = Double(resultScore)
        if let qstScore = qstDetailLevel2?.score{
            score = QSFunc.recalculateScore(userScore: Double(resultScore),
                                                paperQstScore: qstScore)
        }
       
        //isGeneral
        qstDetailLevel2?.qst_detail?.recordResult = recordResult
        qstDetailLevel2?.qst_detail?.setUserAnswer(answer: savePath ?? "")
        qstDetailLevel2?.userScore = score
        recordButton.isSelected = false
        recordPro.stopAnimation()
        recordLabel.text = "重新录音"
        
    }
    func playQsAudio(url:String){
        AVPlayerManger.shared.playURL(url: URL(string: url),
                                      finishBlock: {[weak self]  in
            guard let self = self else {return}
            self.qsCurTimeLabel.text =  "00:00"
            self.progressView.progress =  0.0
            self.playBtn.pauseButton()
        },progress:  {[weak self] cur in
            guard let self = self else {return}
            self.qsCurTimeLabel.text = DateUtil.parseTime(timeInMillis: cur * 1000)
            self.progressView.progress = Float(cur) / Float(qsTimeTotal)
        })
    }
    /*
     播放自己的录音
     */
    func playMeRecordAudio(url:String){
        var total = 0
        AVPlayerManger.shared.playURL(url: URL(string: url),startBlock: {[weak self]  duration in
            guard let self = self else { return }
            total = Int(duration)
            meLabel.text = "我的录音" + DateUtil.parseTime(timeInSec: Int(duration))
            let duration =  QSFunc.getLocalAudioDuration(url: url)
            mePro.animate(fromAngle: 360, toAngle: 0, duration: TimeInterval(duration), completion: nil)
        }, finishBlock: {[weak self]  in
            guard let self = self else {return}
            meLabel.text = "我的录音"
        },progress:  {[weak self] cur in
            guard let self = self else {return}
            meLabel.text = "我的录音" + DateUtil.parseTime(timeInSec:total -  cur)
        })
    }
    
}
//MARK:  测评回调 SSOralEvaluatingManagerDelegate
extension ConversationCell:SSOralEvaluatingManagerDelegate{
    /*
     引擎初始化成功
     */
    func oralEvaluatingInitSuccess() {
        log.debug("")
    }
    /*
     评测开始
     */
    func oralEvaluatingDidStart() {
        log.debug("")
    }
    /*
     评测停止
     */
    func oralEvaluatingDidStop() {
        log.debug("")
    }
    /*
     评测完成后的结果
     */
    func oralEvaluatingDidEnd(withResult result: [AnyHashable : Any]?, isLast: Bool) {
        log.debug("result = \(result)")
        handleSpeakResult(result: result as? [String : Any])
       
    }
    /*
     每次测评对应的request_id回调。
     */
    func oralEvaluatingReturnRequestId(_ request_id: String?) {
        log.debug("request_id = \(request_id)")
    }
    /*
     录音数据回调
     */
    func oralEvaluatingRecordingBuffer(_ recordingData: Data?) {
        log.debug("recordingData =\(recordingData)")
    }
    /*
     the duration of the audio is over the limit
     
     */
    func oralEvaluatingDidEndError(_ error: Error?, requestId request_id: String?) {
        log.debug("error =\(error),request_id =\(request_id)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            recordPro.stopAnimation()
            recordButton.isSelected = false
        }

//        lsKeyWindow?.makeToast(error?.localizedDescription)

    }
}
