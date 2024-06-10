//
//  EQTableCell.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/10.
//

import UIKit

class EQTableCell: UITableViewCell {
    
    var tableModelArr: [EQTableModel]!

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: contentView.bounds)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TDCell.self, forCellWithReuseIdentifier: NSStringFromClass(TDCell.self))
        return collectionView
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension EQTableCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        tableModelArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tableModelArr[section].expansionTrModelArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TDCell.self), for: indexPath) as! TDCell
        cell.tdModel = tableModelArr[indexPath.section].expansionTrModelArr[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        tableModelArr[indexPath.section].expansionTrModelArr[indexPath.item].size
    }
}

extension EQTableCell {
    
    class TDCell: UICollectionViewCell {
        
        var tdModel: EQTableTdModel!
        
        lazy var lab: UILabel = {
            let lab = UILabel(frame: bounds)
            lab.font = tdModel.configModel.font
            lab.textColor = tdModel.configModel.textColor
            lab.textAlignment = tdModel.configModel.textAlignment
            lab.text = tdModel.content
            lab.numberOfLines = 0
            lab.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth, .flexibleHeight]
            return lab
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(lab)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
