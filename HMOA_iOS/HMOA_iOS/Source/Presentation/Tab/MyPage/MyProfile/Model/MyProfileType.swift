//
//  MyProfileType.swift
//  HMOA_iOS
//
//  Created by 임현규 on 2023/05/08.
//

import Foundation

enum MyProfileType: Int, CaseIterable {
    case nickname
    case year
    case sex
    
    var title: String {
        switch self {
        case .nickname:
            return "닉네임"
        case .year:
            return "출생연도"
        case .sex:
            return "성별"
        }
    }
}
