//
//  ChangeSexReactor.swift
//  HMOA_iOS
//
//  Created by 정지훈 on 2023/03/31.

import UIKit

import ReactorKit
import RxCocoa

class ChangeSexReactor: Reactor {
    let initialState: State
    
    enum Action {
        case didTapWomanButton
        case didTapManButton
        case didTapChangeButton
    }
    
    enum Mutation {
        case setCheckWoman(Bool)
        case setCheckMan(Bool)
        case setPopMyPage(Bool)
    }
    
    struct State {
        var isCheckedWoman: Bool = false
        var isCheckedMan: Bool = false
        var isPopMyPage: Bool = false
        var isSexCheck: Bool = false
    }
    
    init() {
        initialState = State()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .didTapManButton:
            return .just(.setCheckMan(true))
        case .didTapWomanButton:
            return .just(.setCheckWoman(true))
        case .didTapChangeButton:
            return .concat([
                .just(.setPopMyPage(true)),
                .just(.setPopMyPage(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var state = state
        
        switch mutation {
        case .setCheckMan(let isChecked):
            state.isCheckedMan = isChecked
            state.isCheckedWoman = !isChecked
            state.isSexCheck = isChecked
        case .setCheckWoman(let isChecked):
            state.isCheckedWoman = isChecked
            state.isCheckedMan = !isChecked
            state.isSexCheck = isChecked
        case .setPopMyPage(let isPop):
            state.isPopMyPage = isPop
        }
        
        return state
    }
}
        
