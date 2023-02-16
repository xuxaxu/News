import UIKit.UIImage

extension Store where Value == AppState {
    func getNewsListItem(at index: Int) -> NewsListItem? {
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
    func getArticle(at index: Int) -> Article? {
        guard index < state.items.count else {
            return nil
        }
        let article = state.items[index]
        let image: UIImage?
        if let url = article.urlToImage {
            image = state.images[url]
        } else {
            image = nil
        }
        return Article(source: article.source,
                       title: article.title,
                       description: article.description,
                       image: image,
                       date: article.date,
                       url: article.url,
                       urlToImage: article.urlToImage)
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
