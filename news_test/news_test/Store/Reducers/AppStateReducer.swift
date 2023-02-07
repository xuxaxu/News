import UIKit
import Foundation

func reducer(_ state: inout AppState, _ action: AppAction) {
    switch action {
    case .items(let itemAction):
        pullback(itemReducer,
                 get: { $0.items },
                 set: { $0.items = $1 })(&state, itemAction)
        
    case .page(let pageAction):
        pullback(intReducer, get: { $0.currentPage }, set: { $0.currentPage = $1 })(&state, pageAction)
    case .images(let imageAction):
        pullback(imagesDictionaryReducer, get: { $0.images }, set: { $0.images = $1 })(&state, imageAction)
    }
}

func combine(_ reducers: (inout AppState, AppAction) -> Void...) -> (inout AppState, AppAction) -> Void {
    return { state, action in
        for reducer in reducers {
            reducer(&state, action)
        }
    }
}

func pullback<LocalValue, GlobalValue, Action>(_ reducer: @escaping (inout LocalValue, Action) -> Void,
                                       get: @escaping (GlobalValue) -> LocalValue,
                                       set: @escaping (inout GlobalValue, LocalValue) -> Void) -> (inout GlobalValue, Action) -> Void {
    return { globalValue, action in
        var localValue = get(globalValue)
        reducer(&localValue, action)
        set(&globalValue, localValue)
    }
}
