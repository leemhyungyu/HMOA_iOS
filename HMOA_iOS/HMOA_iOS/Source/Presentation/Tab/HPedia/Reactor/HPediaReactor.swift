//
//  HPediaReactor.swift
//  HMOA_iOS
//
//  Created by 정지훈 on 2023/04/05.
//

import Foundation

import ReactorKit
import RxCocoa

class HPediaReactor: Reactor {
    var initialState: State
    
    enum Action {
        
    }
    
    struct State {
        var guideSectionItems: [HPediaGuideData] = HPediaGuideData.list
        var tagSectionItems: [HPediaTagData] = HPediaTagData.list
    }
    
    enum Mutation {
        
    }
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
    }
}
