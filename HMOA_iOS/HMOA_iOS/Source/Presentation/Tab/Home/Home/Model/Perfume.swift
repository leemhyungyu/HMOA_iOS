//
//  Perfume.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/02/20.
//

import UIKit

struct Perfume: Equatable, Hashable {
    var perfumeId: Int
    var titleName: String
    var content: String
    var image: UIImage
    var isLikePerfume: Bool
}
