//
//  EQTableCell.swift
//  ExamQuestionType
//
//  Created by Howard-Zjun on 2024/06/10.
//

import UIKit

class EQTableCell: UITableViewCell {
    
    var tableModelArr: [EQTableModel]! {
        didSet {
            collectionView.reloadData()
        }
    }

    lazy var collectionView: UICollectionView = {
        let layout = TableCollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.delegate = self
        let collectionView = UICollectionView(frame: .init(x: 0, y: 0, width: UIApplication.shared.keyWindow!.frame.width, height: 400), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TDCell.self, forCellWithReuseIdentifier: NSStringFromClass(TDCell.self))
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let itemFrame = itemFrame(indexPath: indexPath)
//        return .init(width: itemFrame.width, height: itemFrame.height)
//    }
}

// MARK: - TableCollectionViewFlowLayoutDeleagte
extension EQTableCell: TableCollectionViewFlowLayoutDeleagte {
    
    func model(indexPath: IndexPath) -> EQTableTdModel {
        tableModelArr[indexPath.section].expansionTrModelArr[indexPath.item]
    }
    
    func itemFrame(indexPath: IndexPath) -> CGRect {
        let contentWidth = collectionView.frame.width - contentView.safeAreaInsets.left - contentView.safeAreaInsets.right
        let contentHeight = collectionView.frame.height - contentView.safeAreaInsets.top - contentView.safeAreaInsets.bottom
        
        let col = tableModelArr[0].theadModel?.trModelArr.first?.tdModelArr.count ?? tableModelArr[0].trModelArr[0].tdModelArr.count
        let row = (tableModelArr[0].theadModel?.trModelArr.count ?? 0) + tableModelArr[0].trModelArr.count
        
        let colSpan = floor(contentWidth / CGFloat(col))
        let rowSpan = floor(contentHeight / CGFloat(row))
        
        let model = model(indexPath: indexPath)
        return CGRect(x: CGFloat(model.xNum) * colSpan, y: CGFloat(model.yNum) * rowSpan, width: CGFloat(model.widthNum) * colSpan, height: CGFloat(model.heightNum) * rowSpan)
    }
}

extension EQTableCell {
    
    class TDCell: UICollectionViewCell {
        
        var tdModel: EQTableTdModel! {
            didSet {
                lab.font = tdModel.configModel.font
                lab.textColor = tdModel.configModel.textColor
                lab.textAlignment = tdModel.configModel.textAlignment
                lab.layer.borderColor = tdModel.configModel.boardColor.cgColor
                lab.layer.borderWidth = tdModel.configModel.boardWidth
                lab.backgroundColor = tdModel.configModel.backgroundColor
                lab.text = tdModel.content
            }
        }
        
        lazy var lab: UILabel = {
            let lab = UILabel(frame: bounds)
            lab.numberOfLines = 0
            lab.adjustsFontSizeToFitWidth = true
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
