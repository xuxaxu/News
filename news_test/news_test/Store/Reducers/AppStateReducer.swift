import UIKit
import Foundation

func reducer(_ state: inout AppState, _ action: AppAction) {
    switch action {
    case .items(let itemAction):
        pullback(itemReducer,
                 get: { $0.items },
                 set: { $0.items = $1 })(&state, itemAction)
    case .page(let pageAction):
        pullback(intReducer,
                 get: { $0.currentPage },
                 set: { $0.currentPage = $1 })(&state, pageAction)
    case .images(let imageAction):
        pullback(imagesDictionaryReducer,
                 get: { $0.images },
                 set: { $0.images = $1 })(&state, imageAction)
    case .dataFromPersistance(let persistanceAction):
        pullback(persistanceReducer,
                 get: { $0.dataFromPersistance },
                 set: { $0.dataFromPersistance = $1 })(&state, persistanceAction)
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


enum AppAction {
    case items(ItemAction)
    case page(PageAction)
    case images(ImageAction)
    case dataFromPersistance(DataFromPersistaneAction)
}

enum PageAction {
    case incrementPage
    case resetPage
}

enum ItemAction {
    case addArticle(Article)
    case clear
}

enum ImageAction {
    case setImage(image: UIImage, url: URL)
}

enum DataFromPersistaneAction {
    case setFromPersistance
    case setFromNet
}
