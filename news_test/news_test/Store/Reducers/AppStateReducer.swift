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
    case .currentArticle(let articleAction):
        pullback(currentArticleReducer,
                 get: { $0.currentArticle },
                 set: { $0.currentArticle = $1 })(&state, articleAction)
    }
}

enum AppAction {
    case items(ItemAction<Article>)
    case page(PageAction)
    case images(ImageAction)
    case dataFromPersistance(DataFromPersistaneAction)
    case currentArticle(CurrentArticleAction)
}
