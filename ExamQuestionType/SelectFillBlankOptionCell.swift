//
//  SelectFillBlankOptionCell.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/07/13.
//

import UIKit

class SelectFillBlankOptionCell: UICollectionViewCell {
    
    var index: Int!
    
    var options: [String]!
    
    var selectIndex: Int?
    
    var selectOptionBlock: ((Int, Int) -> Void)?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .init(x: 10, y: 0, width: contentView.kwidth - 20, height: contentView.kheight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OptionCell.self)
        return tableView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(index: Int, options: [String], selectIndex: Int?) {
        self.index = index
        self.options = options
        self.selectIndex = selectIndex
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SelectFillBlankOptionCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(OptionCell.self, indexPath: indexPath)
        cell.lab.text = options[indexPath.row]
        cell.icon.image = .init(systemName: selectIndex == indexPath.row ? "checkmark.seal" : "seal")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectOptionBlock?(index, indexPath.row)
        tableView.reloadData()
    }
}

extension SelectFillBlankOptionCell {
    
    class OptionCell: UITableViewCell {
        
        lazy var icon: UIImageView = {
            let icon = UIImageView(frame: .init(x: 10, y: (contentView.kheight - 30) * 0.5, width: 30, height: 30))
            icon.image = .init(named: "seal")
            return icon
        }()
        
        lazy var lab: UILabel = {
            let lab = UILabel(frame: .init(x: icon.kmaxX + 10, y: 5, width: contentView.kwidth - icon.kmaxX - 10 - 10, height: contentView.kheight - 10))
            lab.font = .systemFont(ofSize: 18)
            lab.textColor = .black
            lab.numberOfLines = 0
            lab.textAlignment = .left
            return lab
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(icon)
            contentView.addSubview(lab)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
