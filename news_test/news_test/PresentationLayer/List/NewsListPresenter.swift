import Foundation

class NewsListPresenter {
    
    private var serviceCoordinator: BuisnessLogic
    
    private var isLodaing = false
    
    public weak var view: NewsListViewInput? {
        didSet {
            view?.update(with: .loading)
        }
    }
    
    init(serviceCoordinator: BuisnessLogic) {
        self.serviceCoordinator = serviceCoordinator
        subscribe()
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(newsChanges(_:)),
                                               name: .StateChanges,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(imageLoaded(_:)),
                                               name: .ImageLoadedForNews,
                                               object: nil)
    }
    
    @objc private func newsChanges(_ notification: Notification) {
        guard let index = notification.object as? Int else {
            return
        }
        if index < 0 {
            view?.update(with: .loading)
        } else {
            view?.update(with: .success(nil))
            isLodaing = false
        }
    }
    @objc private func imageLoaded(_ notification: Notification) {
        guard let index = notification.object as? Int else {
            return
        }
        view?.update(with: .success(index))
    }
}

extension NewsListPresenter: NewsListViewOutput {
    
    func getTitle() -> String {
        GlobalConstants.domains
    }
    
    func getItem(for index: IndexPath) -> NewsListItem? {
        let item = serviceCoordinator.getListItem(for: index.row)
        if serviceCoordinator.countOfNews() - index.row < 5, !isLodaing {
            serviceCoordinator.askNextPortionOfNews()
            isLodaing = true
        }
        return item
    }
    
    func countOfItems() -> Int {
        serviceCoordinator.countOfNews()
    }
    
    func askForUpdate() {
        serviceCoordinator.askNews()
    }
    
    func scroll() {
        
    }
    
    func itemSelected(indexPath: IndexPath) {
        serviceCoordinator.chooseArticle(for: indexPath.row)
        view?.navigateToDetail()
    }
    
    
}
