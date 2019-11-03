//
//  TableViewCell.swift
//  SearchPhoto
//
//  Created by Andrey Alhimchenkov on 11/4/19.
//  Copyright © 2019 Andrey Alhimchenkov. All rights reserved.
//

import Foundation
import UIKit


class TableViewCell: UITableViewCell {
    
    var searchImage = UIImageView();
    var searchResult = UILabel();
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier);
        
        
        searchResult.font = UIFont.boldSystemFont(ofSize: 16);
        searchResult.textAlignment = .left;
        searchResult.textColor = .black;
        
        searchImage.contentMode = .scaleAspectFit;
        searchImage.layer.cornerRadius = 10.0;
        searchImage.clipsToBounds = true;
        
        addSubview(searchImage);
        addSubview(searchResult);
        
        searchImage.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 5, paddingLeft: 5, paddingBottom: 5, paddingRight: 0, width: 100, height: 100, enableInsets: false);
        
        searchResult.anchor(top: searchImage.centerYAnchor, left: searchImage.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 0, enableInsets: false);
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented");
    }
        
    
}
