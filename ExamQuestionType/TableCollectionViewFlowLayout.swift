//
//  TableCollectionViewFlowLayout.swift
//  ExamQuestionType
//
//  Created by ios on 2024/6/11.
//

import UIKit

protocol TableCollectionViewFlowLayoutDeleagte {
    
    func model(indexPath: IndexPath) -> EQTableTdModel
    
    func itemFrame(indexPath: IndexPath) -> CGRect
}

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
