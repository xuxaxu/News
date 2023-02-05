import Foundation

class Store {
    var items = [Article]()
    var currentPage: Int = 1
    var detailed = [Int: Int]()
    
    func addArticle(_ article: Article) {
        items.append(article)
        NotificationCenter.default.post(name: .NewsItemsChanges,
                                        object: items.count - 1)
    }
    
    func pagesLoadedFromCurrent(_ loaded: Int) {
        if loaded > items.count {
            currentPage += 1
        }
    }
    
    func getArticle(at index: Int) -> (Article, Int)? {
        if index < items.count {
            return (items[index], detailed[index] ?? 0)
        }
        return nil
    }
    func count() -> Int {
        items.count
    }
    func clear() {
        items = []
        currentPage = 1
        NotificationCenter.default.post(name: .NewsItemsChanges,
                                        object: -1)
    }
}

extension Notification.Name {
    static let NewsItemsChanges = Notification.Name(
        rawValue: "com.News-test.Store.changesInNewsArray")
}
