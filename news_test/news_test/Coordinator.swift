import UIKit

protocol Coordinator {
    func openDetail(in viewController: UIViewController) -> Void
    func start() -> UINavigationController
}

public class CoordinatorImp: Coordinator {
     
    static let shared: CoordinatorImp = .init()
    
    func start() -> UINavigationController {
        let builder = NewsListBuilder()
        let navigationController = UINavigationController()
        navigationController.viewControllers = [builder.viewController]
        return navigationController
    }
    
    func openDetail(in viewController: UIViewController) {
        let detailBuilder = DetailBuilder()
        viewController.show(detailBuilder.viewController, sender: nil)
    }
}
