import Foundation

protocol ServiceCoordinator {
    func askNews() -> Void
    func askNextPortionOfNews() -> Void
    func countOfNews() -> Int
    func getListItem(for index: Int) -> NewsListItem?
    func openDetail(_ index: Int) -> Void
}

class ServiceCoordinatorImp: ServiceCoordinator {
    
    private let store: Store
    private let newsListService: NewsListNetworkService
    private let parser: ArticleNetworkParser
    private let imageService: ImagesNetworkService
    
    static let shared: ServiceCoordinatorImp = .init(
        newsListNetworkService: NewsListNetworkServiceImp(networkClient: NetworkClientImp(urlSession: URLSession(configuration: .default))),
        articleParser: ArticleNetworkParserImp(),
        imageNetworkService: ImagesNetworkServiceImp(networkClient: NetworkClientImp(urlSession: URLSession(configuration: .default)))
    )
    
    init(newsListNetworkService: NewsListNetworkService,
         articleParser: ArticleNetworkParser,
         imageNetworkService: ImagesNetworkService) {
        self.store = Store()
        self.newsListService = newsListNetworkService
        self.parser = articleParser
        self.imageService = imageNetworkService
        askNextPortionOfNews()
    }
    func askNews() {
        store.clear()
        askNextPortionOfNews()
    }
    func askNextPortionOfNews() {
        newsListService.getNews(page: store.currentPage) {[weak self] result in
            switch result {
            case .failure(let error):
                NotificationCenter.default.post(name: .ErrorDuringNewsLoading, object: error)
            case .success(let response):
                guard let loaded = response.totalResults else {
                    return
                }
                self?.store.pagesLoadedFromCurrent(loaded)
                for netArticle in response.articles {
                    if let article = self?.parser.parse(article: netArticle) {
                        self?.store.addArticle(article)
                        if let imageUrl = article.urlToImage {
                            self?.loadImage(imageUrl, for: (self?.store.count() ?? 1) - 1)
                        }
                    }
                }
            }
        }
    }
    func countOfNews() -> Int {
        store.count()
    }
    func getListItem(for index: Int) -> NewsListItem? {
        store.getArticle(at: index)
    }
    func loadImage(_ url: URL, for index: Int) {
        imageService.getImage(url: url) { [weak self] result in
            switch result {
            case .failure(let error):
                print("image loading error \(error)")
            case .success(let image):
                self?.store.setImage(url, image)
                NotificationCenter.default.post(name: .ImageLoadedForNews, object: index)
            }
        }
    }
    func openDetail(_ index: Int) {
        
    }
}

extension Notification.Name {
    static let ErrorDuringNewsLoading = Notification.Name(
        rawValue: "com.News-test.ServiceCoordinator.errorDuringLoadingNewsOccurs")
    static let ImageLoadedForNews = Notification.Name(
        rawValue: "com.News-test.ServiceCoordinator.imageLoadedForNewsWithIndex")
}
