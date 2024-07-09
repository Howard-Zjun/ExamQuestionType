//
//  QueContentSelectOptionCell.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/07/09.
//

import UIKit

class QueContentSelectOptionCell: UITableViewCell {

    var model: QueContentSelectOptionModel! {
        didSet {
            tableView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
            }
            tableView.reloadData()
        }
    }
    
    var heightObservation: NSKeyValueObservation?
    
    // MARK: - view
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .init(x: 16, y: 0, width: contentView.kwidth - 32, height: 100))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.setEditing(true, animated: false)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - life
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
            make.height.equalTo(100)
        }
        heightObservation = tableView.observe(\.contentSize, options: .new, changeHandler: { tableView, change in
            tableView.snp.updateConstraints { make in
                make.height.equalTo(tableView.contentSize.height)
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        heightObservation?.invalidate()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension QueContentSelectOptionCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(UITableViewCell.self, indexPath: indexPath)
        let option = model.options[indexPath.row]
        if option.contains("<img") {
            if let url = URL(string: option) {
                cell.imageView?.sd_setImage(with: url)
            } else {
                cell.imageView?.image = .init(systemName: "doc")
            }
        } else {
            cell.textLabel?.text = option
        }
        cell.backgroundColor = model.selectIndex == indexPath.row ? .blue : .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        model.selectIndex = indexPath.row
    }
}


