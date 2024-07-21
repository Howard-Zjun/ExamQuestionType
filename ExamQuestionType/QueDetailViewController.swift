//
//  QueDetailViewController.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/30.
//

import UIKit

class QueDetailViewController: UIViewController {

    var queLevel1: QueLevel1!
    
    var index = 0 {
        didSet {
            queLevel2 = queLevel1.queLevel2Arr[index]
        }
    }
    
    var queLevel2: QueLevel2! {
        didSet {
            self.models = queLevel2.resolver(isResult: false)
        }
    }
    
    var models: [QueContentModel] = [] {
        didSet {
            for model in models {
                tableView.register(model.cellType)
                
                if let selectFillBlankModel = model as? QueContentSelectFillBlankModel {
                    selectFillBlankModel.delegate = self
                } else if let fillBlankModel = model as? QueContentFillBlankModel {
                    fillBlankModel.delegate = self
                }
            }
            
            tableView.reloadData()
        }
    }
    
    var tapGesture: UITapGestureRecognizer?
    
    // MARK: - view
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var bottomHandleView: UIView = {
        let bottomHandleView = UIView(frame: .init(x: 0, y: view.kheight - 50, width: view.kwidth, height: 50))
        bottomHandleView.backgroundColor = .init(hex: 0xDBDBDB)
        return bottomHandleView
    }()
    
    lazy var nextBtn: UIButton = {
        let nextBtn = UIButton(frame: .init(x: view.kwidth - 10 - 100, y: 0, width: 100, height: bottomHandleView.kheight))
        nextBtn.setTitle("下一个", for: .normal)
        nextBtn.setTitleColor(.black, for: .normal)
        nextBtn.addTarget(self, action: #selector(toNext), for: .touchUpInside)
        return nextBtn
    }()
    
    lazy var previousBtn: UIButton = {
        let previousBtn = UIButton(frame: .init(x: 10, y: 0, width: 100, height: bottomHandleView.kheight))
        previousBtn.setTitle("前一个", for: .normal)
        previousBtn.setTitleColor(.black, for: .normal)
        previousBtn.addTarget(self, action: #selector(toPrevious), for: .touchUpInside)
        return previousBtn
    }()
    
    lazy var optionView: UIView = {
        let optionView = UIView(frame: .init(x: 0, y: 0, width: view.kwidth, height: 100))
        optionView.isHidden = true
        optionView.backgroundColor = .init(hex: 0xDBDBDB)
        return optionView
    }()
    
    lazy var optionTitleLab: UILabel = {
        let optionTitleLab = UILabel(frame: .init(x: 20, y: 0, width: optionView.kwidth - 40, height: 50))
        optionTitleLab.font = .systemFont(ofSize: 18)
        optionTitleLab.textColor = .black
        optionTitleLab.textAlignment = .left
        return optionTitleLab
    }()
    
    lazy var optionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let optionCollectionView = UICollectionView(frame: .init(x: 20, y: optionTitleLab.kmaxY, width: optionView.kwidth - 20, height: optionView.kheight - optionTitleLab.kheight), collectionViewLayout: layout)
        optionCollectionView.isPagingEnabled = true
        optionCollectionView.delegate = self
        optionCollectionView.dataSource = self
        optionCollectionView.register(SelectFillBlankOptionCell.self)
        optionCollectionView.showsVerticalScrollIndicator = false
        return optionCollectionView
    }()
    
    // MARK: - life
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(bottomHandleView)
        bottomHandleView.addSubview(previousBtn)
        bottomHandleView.addSubview(nextBtn)
        view.addSubview(optionView)
        optionView.addSubview(optionTitleLab)
        optionView.addSubview(optionCollectionView)
        
        bottomHandleView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(50)
        }
        previousBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        nextBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(0)
            make.bottom.equalTo(optionView.snp.top)
        }
        optionView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        optionTitleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.height.equalTo(50)
        }
        optionCollectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(optionTitleLab.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    func config(queLevel1: QueLevel1) {
        view.isHidden = false
        self.queLevel1 = queLevel1
        self.index = 0
    }
    
    // MARK: - target
    @objc func toNext() {
        if index + 1 < queLevel1.queLevel2Arr.count {
            index += 1
        }
    }
    
    @objc func toPrevious() {
        if index - 1 >= 0 {
            index -= 1
        }
    }
    
    @objc func keyboardWillShow(_ info: Notification) {
        if let keyboardFrameEnd = info.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            var changeFrame: CGRect
            if let keyWindow = kKeyWindow {
                changeFrame = keyWindow.convert(keyboardFrameEnd, to: view)
            } else {
                changeFrame = UIApplication.shared.keyWindow!.convert(keyboardFrameEnd, to: view)
            }
            if changeFrame.minY < tableView.kmaxY {
                optionCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(view.kheight - changeFrame.minY - 50)
                }
            }
        }
    }
    
    @objc func keyboardDidShow(_ info: Notification) {
        if let tapGesture = tapGesture {
            tableView.removeGestureRecognizer(tapGesture)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignResponder(_:)))
        tapGesture.delegate = self
        tableView.addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
        
        // 在 keyboardWillShow 里加没效果，需要等tableView高度变化稳定后才能加滚动
        // 滚动选中的内容到中心，尽量不被键盘遮挡
        for (index, model) in models.enumerated() {
            if let enterModel = model as? QueContentEssayModel {
                if enterModel.isFocuns {
                    tableView.scrollToRow(at: .init(row: index, section: 0), at: .top, animated: true)
                    break
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ info: Notification) {
        optionCollectionView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        for (index, model) in models.enumerated() {
            if let fillBlankModel = model as? QueContentFillBlankModel {
                fillBlankModel.focunsIndex = nil
                let cell = tableView.cellForRow(at: .init(row: index, section: 0)) as? QueContentFillBlankCell
                cell?.textView.resignFirstResponder()
            } else if let tableFillBlankModel = model as? QueContentTableModel {
                let cell = tableView.cellForRow(at: .init(row: index, section: 0)) as? QueContentTableCell

                for (trIndex, trModel) in tableFillBlankModel.tableModel.expansionTrModelArr.enumerated() {
                    trModel.focunsIndex = nil
                    
                    let trCell = cell?.collectionView.cellForItem(at: .init(item: trIndex, section: 0)) as? QueContentTableCell.QCTCell
                    trCell?.textField.resignFirstResponder()
                    trCell?.tdModel = trModel
                }
            } else if let enterModel = model as? QueContentEssayModel {
                enterModel.isFocuns = false
            }
        }
        
        if let tapGesture = tapGesture {
            tableView.removeGestureRecognizer(tapGesture)
            self.tapGesture = nil
        }
    }
    
    @objc func resignResponder(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension QueDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        if let titleModel = model as? QueContentTitleModel {
            let cell = tableView.dequeueReusableCell(QueContentTitleCell.self, indexPath: indexPath)
            cell.model = titleModel
            cell.selectionStyle = .none
            return cell
        } else if let describeModel = model as? QueContentDescribeModel {
            let cell = tableView.dequeueReusableCell(QueContentDescribeCell.self, indexPath: indexPath)
            cell.model = describeModel
            cell.contentSizeWillChange = {
                tableView.beginUpdates()
            }
            cell.contentSizeDidChange = {
                tableView.endUpdates()
            }
            cell.selectionStyle = .none
            return cell
        } else if let essayModel = model as? QueContentEssayModel {
            let cell = tableView.dequeueReusableCell(QueContentEssayCell.self, indexPath: indexPath)
            cell.indexPath = indexPath
            cell.model = essayModel
            cell.contentSizeDidChange = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            cell.actionDidChange = { [weak self] tempIndexPath in
                guard let self = self else { return }
                for (tempIndex, model) in models.enumerated() {
                    if let enterModel = model as? QueContentEssayModel {
                        enterModel.isFocuns = tempIndex == tempIndexPath.row
                    }
                }
            }
            cell.textDidChange = { text in
                essayModel.setAnswer(text: text)
            }
            cell.selectionStyle = .none
            return cell
        } else if let selectFillBlankModel = model as? QueContentSelectFillBlankModel {
            let cell = tableView.dequeueReusableCell(QueContentSelectFillBlankCell.self, indexPath: indexPath)
            cell.model = selectFillBlankModel
            cell.contentSizeBeginChange = {
                tableView.beginUpdates()
            }
            cell.contentSizeDidChange = {
                tableView.endUpdates()
            }
            cell.actionDidChange = { [weak self] index in
                guard let self = self else { return }
                optionView.isHidden = false
                toSubject(index: index)
            }
            cell.selectionStyle = .none
            return cell
        } else if let fillBlankModel = model as? QueContentFillBlankModel {
            let cell = tableView.dequeueReusableCell(QueContentFillBlankCell.self, indexPath: indexPath)
            cell.model = fillBlankModel
            cell.contentSizeWillChange = {
                tableView.beginUpdates()
            }
            cell.contentSizeDidChange = {
                tableView.endUpdates()
            }
            cell.selectionStyle = .none
            return cell
        } else if let imgModel = model as? QueContentImgModel {
            let cell = tableView.dequeueReusableCell(QueContentImgCell.self, indexPath: indexPath)
            cell.model = imgModel
            cell.contentSizeDidChange = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
            cell.selectionStyle = .none
            return cell
        } else if let tableModel = model as? QueContentTableModel {
            let cell = tableView.dequeueReusableCell(QueContentTableCell.self, indexPath: indexPath)
            cell.model = tableModel
            cell.selectionStyle = .none
            return cell
        } else if let videoModel = model as? QueContentVideoModel {
            let cell = tableView.dequeueReusableCell(QueContentVideoCell.self, indexPath: indexPath)
            cell.model = videoModel
            cell.selectionStyle = .none
            return cell
        } else if let voiceModel = model as? QueContentVoiceModel {
            let cell = tableView.dequeueReusableCell(QueContentVoiceCell.self, indexPath: indexPath)
            cell.model = voiceModel
            cell.selectionStyle = .none
            return cell
        } else if let selectOptionModel = model as? QueContentSelectOptionModel {
            let cell = tableView.dequeueReusableCell(QueContentSelectOptionCell.self, indexPath: indexPath)
            cell.model = selectOptionModel
            cell.selectionStyle = .none
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.row]
        return model.estimatedHeight ?? UITableView.automaticDimension
    }
}

// MARK: - QueContentModelDelegate
extension QueDetailViewController: QueContentModelDelegate {
    
    func contentDidChange(model: any QueContentModel) {
        for (index, contentModel) in models.enumerated() {
            if let obj1 = model as? QueContentFillBlankModel, let obj2 = contentModel as? QueContentFillBlankModel, obj1 == obj2 {
                let cell = tableView.cellForRow(at: .init(row: index, section: 0)) as? QueContentFillBlankCell
                cell?.model = obj2
            } else if let obj1 = model as? QueContentSelectFillBlankModel, let obj2 = contentModel as? QueContentSelectFillBlankModel, obj1 == obj2 {
                let cell = tableView.cellForRow(at: .init(row: index, section: 0)) as? QueContentSelectFillBlankCell
                cell?.model = obj2
            }
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension QueDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        for model in models {
            if let selectFillBlankModel = model as? QueContentSelectFillBlankModel {
                return selectFillBlankModel.options.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        for model in models {
            if let selectFillBlankModel = model as? QueContentSelectFillBlankModel {
                let cell = collectionView.dequeueReusableCell(SelectFillBlankOptionCell.self, indexPath: indexPath)
                cell.set(index: indexPath.section, options: selectFillBlankModel.options[indexPath.section], selectIndex: selectFillBlankModel.getAnswer(index: indexPath.section))
                cell.selectOptionBlock = { [weak self] index, position in
                    guard let self = self else { return }
                    selectFillBlankModel.setAnswer(text: Tool.positionToLetter(position: position))
                    
                    let selectFillBlankCell = tableView.cellForRow(at: .init(row: index, section: 0)) as? QueContentSelectFillBlankCell
                    selectFillBlankCell?.model = selectFillBlankModel
                    
                    toSubject(index: index + 1)
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        for model in models {
            if let selectFillBlankModel = model as? QueContentSelectFillBlankModel {
                let count = selectFillBlankModel.options[indexPath.section].count
                return .init(width: collectionView.kwidth, height: CGFloat(count) * 30 + 50)
            }
        }
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0.0
    }
    
    func toSubject(index: Int) {
        for model in models {
            if let selectFillBlankModel = model as? QueContentSelectFillBlankModel {
                // 超过退出
                if index >= selectFillBlankModel.options.count {
                    print("\(NSStringFromClass(Self.self)) \(#function) 跳转 超出")
                    optionCollectionView.reloadData()
                    return
                }
                
                optionTitleLab.text = "\(index + 1)、"
                
                let lastFocusIndex = selectFillBlankModel.focunsIndex
                
                selectFillBlankModel.focunsIndex = index
                
                let selectFillBlankCell = tableView.cellForRow(at: .init(row: index, section: 0)) as? QueContentSelectFillBlankCell
                selectFillBlankCell?.model = selectFillBlankModel
                
                
                if let lastFocusIndex = lastFocusIndex {
                    print("\(NSStringFromClass(Self.self)) \(#function) 跳转到第\(index)个")
                    optionCollectionView.scrollToItem(at: .init(item: 0, section: index), at: index > lastFocusIndex ? .right : .left, animated: true)
                } else {
                    print("\(NSStringFromClass(Self.self)) \(#function) 首次聚焦 跳转到第\(index)个")
                    optionCollectionView.reloadData()
                }
                
                let count = selectFillBlankModel.options[index].count
                optionCollectionView.snp.updateConstraints { make in
                    make.height.equalTo(count * 30 + 50)
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == optionCollectionView {
            let item = Int((scrollView.contentOffset.x + 50) / scrollView.kwidth)
            print("\(NSStringFromClass(Self.self)) \(#function) contentOffset: \(scrollView.contentOffset.x) 手动滚动到第\(item)个")

            optionTitleLab.text = "\(item + 1)、"
            
            for (index, model) in models.enumerated() {
                if let selectFillBlankModel = model as? QueContentSelectFillBlankModel {
                    selectFillBlankModel.focunsIndex = item
                    
                    let selectFillBlankCell = tableView.cellForRow(at: .init(row: index, section: 0)) as? QueContentSelectFillBlankCell
                    selectFillBlankCell?.model = selectFillBlankModel
                    
                    optionCollectionView.reloadItems(at: [.init(item: item, section: 0)])
                    
                    let count = selectFillBlankModel.options[item].count
                    optionCollectionView.snp.updateConstraints { make in
                        make.height.equalTo(count * 30 + 50)
                    }
                }
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension QueDetailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
