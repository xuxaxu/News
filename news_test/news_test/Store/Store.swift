import Foundation
import UIKit

class Store {
    var items = [Article]()
    var currentPage: Int = 1
    var detailed = [Int: Int]()
    var images = [URL: UIImage]()
    
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
    
    func getArticle(at index: Int) -> NewsListItem? {
        guard index < items.count else {
            return nil
        }
        let article = items[index]
        let image: UIImage?
        if let imageUrl = article.urlToImage {
            image = images[imageUrl]
        } else {
            image = nil
        }
        let wawDetailed = detailed[index] ?? 0
        let item = NewsListItem(image: image, title: article.title, detailed: wawDetailed)
            return item

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
    func getImage(for index: Int) -> UIImage? {
        guard index < items.count, let url = items[index].urlToImage else {
            return nil
        }
        return images[url]
    }
    func getImageUrl(for index: Int) -> URL? {
        guard index < items.count else {
            return nil
        }
        return items[index].urlToImage
    }
    func setImage(_ url: URL, _ image: UIImage) {
        images[url] = image
    }
}

extension Notification.Name {
    static let NewsItemsChanges = Notification.Name(
        rawValue: "com.News-test.Store.changesInNewsArray")
}
