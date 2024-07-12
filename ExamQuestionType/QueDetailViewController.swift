//
//  QueDetailViewController.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/30.
//

import UIKit

class QueDetailViewController: UIViewController {

    var queLevel1: QueLevel1!
    
    var queLevel2Arr: [QueLevel2]!
    
    var index: Int = 0 {
        didSet {
            let queLevel2 = queLevel2Arr[index]
            if queLevel2.type == .FillBlank {
                self.models = QueContentResolver.fillBlankResolver(queLevel2: queLevel2, isResult: false)
            } else if queLevel2.type == .SelectFillBlank {
                self.models = QueContentResolver.selectFillBlankResolver(queLevel2: queLevel2, isResult: false)
            } else if queLevel2.type == .Essay {
                self.models = QueContentResolver.essayResolver(queLevel2: queLevel2, isResult: false)
            } else {
                self.models = QueContentResolver.normalResolver(queLevel2: queLevel2, isResult: false)
            }
            for model in models {
                if let fillBlankModel = model as? QueContentFillBlankModel {
                    fillBlankModel.delegate = self
                } else if let selectModel = model as? QueContentSelectFillBlankModel {
                    selectModel.delegate = self
                }
            }
            tableView.reloadData()
        }
    }
    
    var models: [QueContentModel] = [] {
        didSet {
            for model in models {
                tableView.register(model.cellType)
            }
        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var previousBtn: UIButton = {
        let previousBtn = UIButton(frame: .init(x: 0, y: view.kheight - 50, width: view.kwidth * 0.5, height: 50))
        previousBtn.setTitle("前一个", for: .normal)
        previousBtn.setTitleColor(.black, for: .normal)
        previousBtn.addTarget(self, action: #selector(toPrevious), for: .touchUpInside)
        return previousBtn
    }()
    
    lazy var nextBtn: UIButton = {
        let nextBtn = UIButton(frame: .init(x: 0, y: view.kwidth * 0.5, width: view.kwidth * 0.5, height: 50))
        nextBtn.setTitle("下一个", for: .normal)
        nextBtn.setTitleColor(.black, for: .normal)
        nextBtn.addTarget(self, action: #selector(toNext), for: .touchUpInside)
        return nextBtn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
        }
    }
    
    func config(queLevel1: QueLevel1) {
        view.isHidden = false
        self.queLevel1 = queLevel1
        self.queLevel2Arr = queLevel1.queLevel2Arr
        
        self.index = 0
    }
    
    // MARK: - target
    @objc func toPrevious() {
        if index == 0 {
            return
        }
        index -= 1
    }
    
    @objc func toNext() {
        if index == queLevel2Arr.count {
            return
        }
        index += 1
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
            cell.model = essayModel
            cell.contentSizeWillChange = {
                tableView.beginUpdates()
            }
            cell.contentSizeDidChange = {
                tableView.endUpdates()
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
            cell.selectionStyle = .none
            return cell
        } else if let selectModel = model as? QueContentSelectFillBlankModel {
            let cell = tableView.dequeueReusableCell(QueContentSelectFillBlankCell.self, indexPath: indexPath)
            cell.model = selectModel
            cell.contentSizeBeginChange = {
                tableView.beginUpdates()
            }
            cell.contentSizeDidChange = {
                tableView.endUpdates()
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
            if let obj1 = model as? NSObject, let obj2 = contentModel as? NSObject, obj1 == obj2 {
                tableView.reloadRows(at: [.init(row: index, section: 0)], with: .none)
            }
        }
    }
}
