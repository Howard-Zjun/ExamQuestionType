//
//  QueContentTableCell.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit

class QueContentTableCell: UITableViewCell {

    var model: QueContentTableModel! {
        didSet {
            if let suffixContent = model.tableModel.suffixContent {
                suffixLab.text = suffixContent
            } else {
                suffixLab.text = ""
            }
            
            collectionView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
            }
        }
    }

    // MARK: - view
    lazy var collectionView: UICollectionView = {
        let layout = TableCollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        layout.delegate = self
        let collectionView = UICollectionView(frame: .init(x: 20, y: 0, width: contentView.kwidth - 40, height: 300), collectionViewLayout: layout)
        collectionView.layer.borderWidth = 1
        collectionView.layer.borderColor = UIColor.black.cgColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(QCTCell.self, forCellWithReuseIdentifier: NSStringFromClass(QCTCell.self))
        return collectionView
    }()
    
    lazy var suffixLab: UILabel = {
        let suffixLab = UILabel(frame: .init(x: 20, y: collectionView.frame.maxY, width: contentView.kwidth - 40, height: 50))
        suffixLab.font = .systemFont(ofSize: 18)
        suffixLab.textColor = .black
        suffixLab.textAlignment = .left
        suffixLab.numberOfLines = 0
        return suffixLab
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        contentView.addSubview(suffixLab)
        collectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(0)
            make.height.equalTo(300)
        }
        suffixLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension QueContentTableCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model.tableModel.expansionTrModelArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(QCTCell.self), for: indexPath) as! QCTCell
        cell.tdModel = model.tableModel.expansionTrModelArr[indexPath.item]
        return cell
    }
}

// MARK: - TableCollectionViewFlowLayoutDeleagte
extension QueContentTableCell: TableCollectionViewFlowLayoutDeleagte {
    
    func model(indexPath: IndexPath) -> EQTableTdModel {
        model.tableModel.expansionTrModelArr[indexPath.item]
    }
    
    func itemFrame(indexPath: IndexPath) -> CGRect {
        let contentWidth = collectionView.frame.width
        let contentHeight = collectionView.frame.height
        
        let col = model.tableModel.theadModel?.trModelArr.first?.tdModelArr.count ?? model.tableModel.trModelArr[0].tdModelArr.count
        let row = (model.tableModel.theadModel?.trModelArr.count ?? 0) + model.tableModel.trModelArr.count
        
        let colSpan = floor(contentWidth / CGFloat(col))
        let rowSpan = floor(contentHeight / CGFloat(row))
        
        let model = model(indexPath: indexPath)
        let x = CGFloat(model.xNum) * colSpan
        let y = CGFloat(model.yNum) * rowSpan
        let height = CGFloat(model.heightNum) * rowSpan
        
        if model.isLast { // 由于 floor 取小值，所以一行单元可能占不满，所以特殊处理
            return CGRect(x: x, y: y, width: contentWidth - x, height: height)
        } else {
            return CGRect(x: x, y: y, width: CGFloat(model.widthNum) * colSpan, height: height)
        }
    }
}

extension QueContentTableCell {
    
    class QCTCell: UICollectionViewCell {
        
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
            return lab
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - TableCollectionViewFlowLayoutDeleagte
protocol TableCollectionViewFlowLayoutDeleagte {
    
    func model(indexPath: IndexPath) -> EQTableTdModel
    
    func itemFrame(indexPath: IndexPath) -> CGRect
}

// MARK: - TableCollectionViewFlowLayout
class TableCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var attributesArray: [UICollectionViewLayoutAttributes] = []
    
    var delegate: TableCollectionViewFlowLayoutDeleagte?
    
    override func prepare() {
        super.prepare()
        weak var collectionView = collectionView
        guard let collectionView = collectionView else {
            return
        }
        var attributesArray: [UICollectionViewLayoutAttributes] = []
        for section in 0..<(collectionView.dataSource?.numberOfSections?(in: collectionView) ?? 0) {
            for item in 0..<(collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0) {
                let layoutAttributes = layoutAttributesForItem(at: .init(item: item, section: section))!
                attributesArray.append(layoutAttributes)
            }
        }
        self.attributesArray = attributesArray
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attributesArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let temp = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        if let tempFrame = delegate?.itemFrame(indexPath: indexPath) {
            temp.frame = tempFrame
        }
        return temp
    }
}
