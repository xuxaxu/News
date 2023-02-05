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
    
    static let shared: ServiceCoordinatorImp = .init(
        newsListNetworkService: NewsListNetworkServiceImp(networkClient: NetworkClientImp(urlSession: URLSession(configuration: .default))),
        articleParser: ArticleNetworkParserImp()
    )
    
    init(newsListNetworkService: NewsListNetworkService,
         articleParser: ArticleNetworkParser) {
        self.store = Store()
        self.newsListService = newsListNetworkService
        self.parser = articleParser
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
                    }
                }
            }
        }
    }
    func countOfNews() -> Int {
        store.count()
    }
    func getListItem(for index: Int) -> NewsListItem? {
        guard let (article, wasDetailed) = store.getArticle(at: index) else {
            return nil
        }
        return NewsListItem(image: article.image, title: article.title, detailed: wasDetailed)
    }
    func openDetail(_ index: Int) {
        
    }
}

extension Notification.Name {
    static let ErrorDuringNewsLoading = Notification.Name(
        rawValue: "com.News-test.ServiceCoordinator.errorDuringLoadingNewsOccurs")
}
