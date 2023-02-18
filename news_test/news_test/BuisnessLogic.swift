import Foundation

protocol BuisnessLogic {
    func askNews() -> Void
    func askNextPortionOfNews() -> Void
    func countOfNews() -> Int
    func getListItem(for index: Int) -> NewsListItem?
    func chooseArticle(for index: Int) -> Void
    func currentArticle() -> Article?
    func getCurrentURLAction() -> () -> URL?
}

class BuisnessLogicImp: BuisnessLogic {
    
    private let store: Store<AppState, AppAction>
    private let newsListService: NewsListNetworkService
    private let parser: ArticleNetworkParser
    private let imageService: ImagesNetworkService
    private let persistanceService: CoreDataPersistance<Article>
    
    static let shared: BuisnessLogicImp = .init(
        newsListNetworkService: NewsListNetworkServiceImp(networkClient: NetworkClientImp(urlSession: URLSession(configuration: .default))),
        articleParser: ArticleNetworkParserImp(),
        imageNetworkService: ImagesNetworkServiceImp(networkClient: NetworkClientImp(urlSession: URLSession(configuration: .default))),
        persistanceService: CoreDataPersistance(itemToCoreDataItem: CoreDataPersistance<Article>.fillCoreDataArticleFromArticle,
                                                coreDataItemToItem: CoreDataPersistance<Article>.getArticle)
    )
    
    init(newsListNetworkService: NewsListNetworkService,
         articleParser: ArticleNetworkParser,
         imageNetworkService: ImagesNetworkService,
         persistanceService: CoreDataPersistance<Article>) {
        self.store = Store(state: AppState(), reducer: reducer(_:_:))
        self.newsListService = newsListNetworkService
        self.parser = articleParser
        self.imageService = imageNetworkService
        self.persistanceService = persistanceService
    }
    func askNews() {
        clearArticles()
        store.send(.dataFromPersistance(.setFromNet))
        askNextPortionOfNews()
    }
    func askNextPortionOfNews() {
        guard !store.state.dataFromPersistance else {
            return
        }
        store.send(.page(.incrementPage))
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
                        self.store.send(.items(.addElement(article)))
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
        store.getNewsListItem(at: index)
    }
    func loadImage(_ url: URL, for index: Int) {
        imageService.getImage(url: url) { [weak self] result in
            switch result {
            case .failure(let error):
                print("image loading error \(error)")
            case .success(let image):
                self?.store.send(.images(.setImage(image: image, url: url)))
                self?.persistanceService.postImage(image, url: url, completion: {_ in})
                NotificationCenter.default.post(name: .ImageLoadedForNews, object: index)
            }
        }
    }
    func chooseArticle(for index: Int) {
        let article = store.getArticle(at: index)
        store.send(.currentArticle(.setCurrentArticle(article)))
    }
    func currentArticle() -> Article? {
        store.state.currentArticle
    }
    private func turnToPersistance() {
        if !store.state.dataFromPersistance {
            store.send(.dataFromPersistance(.setFromPersistance))
            clearArticles()
            getArticlesFromPersistance()
        }
    }
    private func turnToNet() {
        if store.state.dataFromPersistance {
            store.send(.dataFromPersistance(.setFromNet))
            persistanceService.deleteAllImages(completion: {_ in })
        }
    }
    private func saveArticles() {
        persistanceService.postAllItems(store.state.items, completion: {_ in } )
    }
    private func getArticlesFromPersistance() {
        persistanceService.getAllItems { [weak self] result in
            switch result {
            case .failure(let error):
                NotificationCenter.default.post(name: .ErrorDuringNewsLoading, object: error)
            case .success(let items):
                for item in items {
                    self?.store.send(.items(.addElement(item)))
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
                    self?.store.send(.images(.setImage(image: item.value, url: item.key)))
                }
            }
        }
    }
    private func clearArticles() {
        store.send(.items(.clear))
        store.send(.page(.resetPage))
    }
    
    func getCurrentURLAction() -> () -> URL? {
        return { [weak self] in
            self?.store.state.currentArticle?.url
        }
    }
}

extension Notification.Name {
    static let ErrorDuringNewsLoading = Notification.Name(
        rawValue: "com.News-test.ServiceCoordinator.errorDuringLoadingNewsOccurs")
    static let ImageLoadedForNews = Notification.Name(
        rawValue: "com.News-test.ServiceCoordinator.imageLoadedForNewsWithIndex")
}
