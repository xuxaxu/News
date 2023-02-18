import UIKit
import Foundation

func reducer(_ state: inout AppState, _ action: AppAction) -> [Effect<AppAction>] {
    var effects: [Effect<AppAction>] = []
    switch action {
    case .items(let itemAction):
        let localEffects = pullback(itemReducer,
                 get: { $0.items },
                 set: { $0.items = $1 })(&state, itemAction)
        for localEffect in localEffects {
            let effectAppAction: () -> AppAction? = {
                if let localAction = localEffect() {
                    return .items(localAction)
                } else {
                    return nil
                }
            }
            effects.append(effectAppAction)
        }
    case .page(let pageAction):
        let localEffects = pullback(intReducer,
                 get: { $0.currentPage },
                 set: { $0.currentPage = $1 })(&state, pageAction)
        for localEffect in localEffects {
            let effectAppAction: () -> AppAction? = {
                if let localAction = localEffect() {
                    return .page(localAction)
                } else {
                    return nil
                }
            }
            effects.append(effectAppAction)
        }
    case .images(let imageAction):
        let localEffects = pullback(imagesDictionaryReducer,
                 get: { $0.images },
                 set: { $0.images = $1 })(&state, imageAction)
        for localEffect in localEffects {
            let effectAppAction: () -> AppAction? = {
                if let localAction = localEffect() {
                    return .images(localAction)
                } else {
                    return nil
                }
            }
            effects.append(effectAppAction)
        }
    case .dataFromPersistance(let persistanceAction):
        let localEffects = pullback(persistanceReducer,
                 get: { $0.dataFromPersistance },
                 set: { $0.dataFromPersistance = $1 })(&state, persistanceAction)
        for localEffect in localEffects {
            let effectAppAction: () -> AppAction? = {
                if let localAction = localEffect() {
                    return .dataFromPersistance(localAction)
                } else {
                    return nil
                }
            }
            effects.append(effectAppAction)
        }
    case .currentArticle(let articleAction):
        let localEffects = pullback(currentArticleReducer,
                 get: { $0.currentArticle },
                 set: { $0.currentArticle = $1 })(&state, articleAction)
        for localEffect in localEffects {
            let effectAppAction: () -> AppAction? = {
                if let localAction = localEffect() {
                    return .currentArticle(localAction)
                } else {
                    return nil
                }
            }
            effects.append(effectAppAction)
        }
    }
    return effects
}

enum AppAction {
    case items(ItemAction<Article>)
    case page(PageAction)
    case images(ImageAction)
    case dataFromPersistance(DataFromPersistanceAction)
    case currentArticle(CurrentArticleAction)
}

