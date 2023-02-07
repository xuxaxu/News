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
        self.store = Store(state: AppState(), reducer: reducer(_:_:))
        self.newsListService = newsListNetworkService
        self.parser = articleParser
        self.imageService = imageNetworkService
    }
    func askNews() {
        store.reduce(.items(.clear))
        store.reduce(.page(.resetPage))
        askNextPortionOfNews()
    }
    func askNextPortionOfNews() {
        newsListService.getNews(page: store.state.currentPage) {[weak self] result in
            switch result {
            case .failure(let error):
                NotificationCenter.default.post(name: .ErrorDuringNewsLoading, object: error)
            case .success(let response):
                self?.store.reduce(.page(.resetPage))
                for netArticle in response.articles {
                    if let article = self?.parser.parse(article: netArticle) {
                        self?.store.reduce(.items(.addArticle(article)))
                        if let imageUrl = article.urlToImage {
                            self?.loadImage(imageUrl, for: (self?.store.count() ?? 1) - 1)
                        }
                    }
                }
            }
        }
        store.reduce(.page(.incrementPage))
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
                self?.store.reduce(.images(.setImage(image: image, url: url)))
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
