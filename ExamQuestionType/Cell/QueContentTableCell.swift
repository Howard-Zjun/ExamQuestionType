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
            collectionView.snp.updateConstraints { make in
                make.top.equalToSuperview().inset(model.contentInset.top)
                make.bottom.equalToSuperview().inset(model.contentInset.bottom)
                make.left.equalToSuperview().inset(model.contentInset.left)
                make.right.equalToSuperview().inset(model.contentInset.right)
                
                if let estimatedHeight = model.estimatedHeight {
                    make.height.equalTo(estimatedHeight)
                } else if let last = model.tableModel.expansionTrModelArr.last {
                    make.height.equalTo(ceil(last.y + last.height))
                } else {
                    make.height.equalTo(model.tableModel.rowCount * 55)
                }
            }
            
            collectionView.reloadData()
        }
    }

    var contentSizeDidChange: (() -> Void)?
    
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
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(0)
            make.bottom.equalToSuperview().inset(0)
            make.height.equalTo(300)
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
        cell.indexPath = indexPath
        cell.actionDidChange = { [weak self] position, indexPath in
            guard let self = self else { return }
            for (index, model) in model.tableModel.expansionTrModelArr.enumerated() {
                if indexPath.item == index {
                    model.focunsIndex = position - model.fillBlankIndexOffset
                } else {
                    model.focunsIndex = nil
                }
            }
            for (index, model) in model.tableModel.expansionTrModelArr.enumerated() {
                let cell = collectionView.cellForItem(at: .init(item: index, section: 0)) as? QCTCell
                cell?.tdModel = model
            }
        }
        cell.contentDidChange = { [weak self] indexPath in
            guard let self = self else { return }
            model.tableModel.adjustSize(contentWidth: kScreenWidth - model.contentInset.left - model.contentInset.right)
            for (index, model) in model.tableModel.expansionTrModelArr.enumerated() {
                let cell = collectionView.cellForItem(at: .init(item: index, section: 0)) as? QCTCell
                cell?.frame = .init(x: model.x, y: model.y, width: model.width, height: model.height)
                print("\(NSStringFromClass(Self.self)) \(#function) index: \(index) width: \(model.width) height: \(model.height)")
                cell?.tdModel = model
            }
            collectionView.snp.updateConstraints { [weak self] make in
                guard let self = self else { return }
                if let last = model.tableModel.expansionTrModelArr.last {
                    make.height.equalTo(ceil(last.y + last.height))
                } else {
                    make.height.equalTo(model.tableModel.rowCount * 55)
                }
            }
            contentSizeDidChange?()
        }
        return cell
    }
}

// MARK: - TableCollectionViewFlowLayoutDeleagte
extension QueContentTableCell: TableCollectionViewFlowLayoutDeleagte {
    
    func model(indexPath: IndexPath) -> EQTableTdModel {
        model.tableModel.expansionTrModelArr[indexPath.item]
    }
}

extension QueContentTableCell {
    
    class QCTCell: UICollectionViewCell, UITextFieldDelegate, UITextViewDelegate {
   
        var actionDidChange: ((Int, IndexPath) -> Void)?
        
        var contentDidChange: ((IndexPath) -> Void)?
        
        var indexPath: IndexPath!
        
        var tdModel: EQTableTdModel! {
            didSet {
                layer.borderColor = tdModel.configModel.boardColor.cgColor
                layer.borderWidth = tdModel.configModel.boardWidth
                backgroundColor = tdModel.configModel.backgroundColor
                textView.attributedText = tdModel.resultAttributed
            }
        }
        
        lazy var textField: UITextField = {
            let textField = UITextField(frame: .init(x: -700, y: 0, width: 30, height: 50))
            textField.autocorrectionType = .no
            textField.returnKeyType = .done
            textField.delegate = self
            textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            return textField
        }()
        
        lazy var textView: DisRangeAbleTextView = {
            let textView = DisRangeAbleTextView(frame: bounds)
            textView.delegate = self
            textView.isEditable = false
            textView.linkTextAttributes = .init()
            textView.adjustsFontForContentSizeCategory = true
            return textView
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(textField)
            contentView.addSubview(textView)
            textView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - target
        @objc func textDidChange(_ sender: UITextField) {
            print("\(NSStringFromClass(Self.self)) \(#function) text: \(sender.text ?? "")")
            var text = sender.text ?? ""
            if text.contains("⌘") {
                text = text.replacingOccurrences(of: "⌘", with: "")
            }
            tdModel.setAnswer(text: text)
            textView.attributedText = tdModel.resultAttributed
            contentDidChange?(indexPath)
        }
        
        // MARK: - UITextViewDelegate
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if URL.absoluteString.hasPrefix(snFillBlankURLPrefix) {
                if let str = URL.absoluteString.components(separatedBy: snSeparate).last, let index = Int(str) {
                    
                    textField.text = tdModel.getAnswer(index: index)
                    
                    print("\(NSStringFromClass(Self.self)) \(#function) index: \(index), text: \(textField.text ?? "")")
                    
                    textField.becomeFirstResponder()
                    
                    actionDidChange?(index, indexPath)
                }
            }
            return false
        }
        
        // MARK: - UITextFieldDelegate
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string == "\n" {
                textField.endEditing(true)
                return false
            }
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if var answer = textField.text {
                answer = answer.replacingOccurrences(of: "⌘", with: "")
                tdModel.setAnswer(text: answer)
            }
        }
    }
}

// MARK: - TableCollectionViewFlowLayoutDeleagte
protocol TableCollectionViewFlowLayoutDeleagte {
    
    func model(indexPath: IndexPath) -> EQTableTdModel
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
        if let model = delegate?.model(indexPath: indexPath) {
            temp.frame = .init(x: model.x, y: model.y, width: model.width, height: model.height)
        }
        return temp
    }
}
