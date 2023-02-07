import Foundation

let itemReducer: (inout [Article], ItemAction) -> Void  = { items, action in
    switch action {
    case .addArticle(let article):
        addArticle(&items, article)
    case .clear:
        clear(&items)
    }
    func addArticle(_ items: inout [Article], _ article: Article) {
        items.append(article)
        NotificationCenter.default.post(name: .NewsItemsChanges,
                                        object: items.count - 1)
    }

    func clear(_ items: inout [Article]) {
        items = []
        NotificationCenter.default.post(name: .NewsItemsChanges,
                                        object: -1)
    }
}
