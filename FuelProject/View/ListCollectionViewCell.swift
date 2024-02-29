//
//  ListCollectionViewCell.swift
//  FuelProject
//
//  Created by Abdulkadir Oruç on 27.02.2024.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell {
    
    lazy var label: UILabel = {
        let lb = UILabel()
        lb.textAlignment = .center
        lb.textColor = .white
        lb.numberOfLines = 0
        lb.font = UIFont(name: "Avenir", size: 18)
        return lb
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
       
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: self.leftAnchor),
            label.rightAnchor.constraint(equalTo: self.rightAnchor),
            label.topAnchor.constraint(equalTo: self.topAnchor),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
