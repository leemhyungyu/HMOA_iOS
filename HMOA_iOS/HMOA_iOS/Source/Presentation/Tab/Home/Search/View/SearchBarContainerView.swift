//
//  SearchBarContainerView.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/02/27.
//

import UIKit

class SearchBarContainerView: UIView {
    
    let searchBar: UISearchBar
    
    init(customSearchBar: UISearchBar) {
        searchBar = customSearchBar
        super.init(frame: .zero)
        addSubview(searchBar)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = frame
    }
}
