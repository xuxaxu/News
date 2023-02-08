import Foundation
import UIKit

class Store: ObservableObject {
    @Published var state: AppState
    
    init(state: AppState, reducer: @escaping (inout AppState, AppAction) -> Void) {
        self.state = state
        self.reducer = reducer
    }
    
    let reducer: (inout AppState, AppAction) -> Void
    
    func reduce(_ action: AppAction) {
        reducer(&state, action)
    }
    
    func getArticle(at index: Int) -> NewsListItem? {
        guard index < state.items.count else {
            return nil
        }
        let article = state.items[index]
        let image: UIImage?
        if let imageUrl = article.urlToImage {
            image = state.images[imageUrl]
        } else {
            image = nil
        }
        let wawDetailed = state.detailed[index] ?? 0
        let item = NewsListItem(image: image, title: article.title, detailed: wawDetailed)
            return item

    }
    func count() -> Int {
        state.items.count
    }
    
    func getImage(for index: Int) -> UIImage? {
        guard index < state.items.count, let url = state.items[index].urlToImage else {
            return nil
        }
        return state.images[url]
    }
    func getImageUrl(for index: Int) -> URL? {
        guard index < state.items.count else {
            return nil
        }
        return state.items[index].urlToImage
    }
}

extension Notification.Name {
    static let NewsItemsChanges = Notification.Name(
        rawValue: "com.News-test.Store.changesInNewsArray")
}
