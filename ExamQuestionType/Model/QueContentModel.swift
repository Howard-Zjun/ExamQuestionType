//
//  QueContentModel.swift
//  ListenSpeak
//
//  Created by ios on 2024/6/11.
//

import UIKit

protocol QueContentModel {

    var cellType: UITableViewCell.Type { get }
    
    var contentInset: UIEdgeInsets { set get } 
}
