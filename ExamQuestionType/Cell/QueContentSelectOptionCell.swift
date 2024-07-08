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
        }
    }
    
    // MARK: - view
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .init(x: 16, y: 0, width: contentView.kwidth - 32, height: 100))
//        tableView.dee
        return tableView
    }()
    
    // MARK: - life
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
