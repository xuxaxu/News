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
    private let persistanceService: PersistanceService
    
    static let shared: ServiceCoordinatorImp = .init(
        newsListNetworkService: NewsListNetworkServiceImp(networkClient: NetworkClientImp(urlSession: URLSession(configuration: .default))),
        articleParser: ArticleNetworkParserImp(),
        imageNetworkService: ImagesNetworkServiceImp(networkClient: NetworkClientImp(urlSession: URLSession(configuration: .default))),
        persistanceService: CoreDataPersistance()
    )
    
    init(newsListNetworkService: NewsListNetworkService,
         articleParser: ArticleNetworkParser,
         imageNetworkService: ImagesNetworkService,
         persistanceService: PersistanceService) {
        self.store = Store(state: AppState(), reducer: reducer(_:_:))
        self.newsListService = newsListNetworkService
        self.parser = articleParser
        self.imageService = imageNetworkService
        self.persistanceService = persistanceService
    }
    func askNews() {
        clearArticles()
        askNextPortionOfNews()
    }
    func askNextPortionOfNews() {
        store.reduce(.page(.incrementPage))
        newsListService.getNews(page: store.state.currentPage) {[weak self] result in
            switch result {
            case .failure(let error):
                NotificationCenter.default.post(name: .ErrorDuringNewsLoading, object: error)
                self?.turnToPersistance()
            case .success(let response):
                guard let self else { return }
                self.turnToNet()
                for netArticle in response.articles {
                    if let article = self.parser.parse(article: netArticle) {
                        self.store.reduce(.items(.addArticle(article)))
                        if let imageUrl = article.urlToImage {
                            self.loadImage(imageUrl, for: (self.store.count()) - 1)
                        }
                    }
                }
                self.saveArticles()
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
                self?.store.reduce(.images(.setImage(image: image, url: url)))
                self?.persistanceService.postImage(image, url: url, completion: {_ in})
                NotificationCenter.default.post(name: .ImageLoadedForNews, object: index)
            }
        }
    }
    func openDetail(_ index: Int) {
        
    }
    private func turnToPersistance() {
        if !store.state.dataFromPersistance {
            store.reduce(.dataFromPersistance(.setFromPersistance))
            clearArticles()
            getArticlesFromPersistance()
        }
    }
    private func turnToNet() {
        if store.state.dataFromPersistance {
            store.reduce(.dataFromPersistance(.setFromNet))
            persistanceService.deleteAllImages(completion: {_ in })
        }
    }
    private func saveArticles() {
        persistanceService.postAllArticles(store.state.items, completion: {_ in } )
    }
    private func getArticlesFromPersistance() {
        persistanceService.getAllArticles { [weak self] result in
            switch result {
            case .failure(let error):
                NotificationCenter.default.post(name: .ErrorDuringNewsLoading, object: error)
            case .success(let items):
                for item in items {
                    self?.store.reduce(.items(.addArticle(item)))
                }
                self?.getImagesFromPersistance()
            }
        }
    }
    private func getImagesFromPersistance() {
        persistanceService.getImages() { [weak self] result in
            switch result {
            case .failure(let error):
                NotificationCenter.default.post(name: .ErrorDuringNewsLoading, object: error)
            case .success(let images):
                for item in images {
                    self?.store.reduce(.images(.setImage(image: item.value, url: item.key)))
                }
            }
        }
    }
    private func clearArticles() {
        store.reduce(.items(.clear))
        store.reduce(.page(.resetPage))
    }
}

extension Notification.Name {
    static let ErrorDuringNewsLoading = Notification.Name(
        rawValue: "com.News-test.ServiceCoordinator.errorDuringLoadingNewsOccurs")
    static let ImageLoadedForNews = Notification.Name(
        rawValue: "com.News-test.ServiceCoordinator.imageLoadedForNewsWithIndex")
}
