import UIKit

class NewsListViewController: UIViewController {

    public var output: NewsListViewOutput
    
    private lazy var tableView: UITableView = UITableView()
    
    init(output: NewsListViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = output.getTitle()
        configureTableView()
        output.askForUpdate()
    }
    private func configureTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NewsListCellView.self, forCellReuseIdentifier: Constants.cellNameForReuseId)
        tableView.estimatedRowHeight = DesignConstants.height
        tableView.rowHeight = DesignConstants.height //UITableView.automaticDimension
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: DesignConstants.offset),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: DesignConstants.offset)
        ])
    }
    private func showError() {
        
    }
    @objc private func refresh() {
        output.askForUpdate()
    }
}

extension NewsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellNameForReuseId, for: indexPath) as? NewsListCellView,
           let item = output.getItem(for: indexPath) {
            cell.configure(with: item)
            return cell
        } else {
            fatalError()
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output.countOfItems()
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         return UILabel()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.itemSelected(indexPath: indexPath)
    }
}

extension NewsListViewController {
    struct Constants {
        static let cellNameForReuseId = "NewsListCellViewReuseId"
    }
}

extension NewsListViewController: NewsListViewInput {
    func update(with data: NewsListState) {
        switch data {
        case .success(let index):
            tableView.refreshControl?.endRefreshing()
            //if let index = index {
              //  tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .left)
            //} else {
                tableView.reloadData()
            //} 
        case .error:
            showError()
        case .loading:
            tableView.refreshControl?.beginRefreshing()
        }
    }
    
    func navigateTo(destination: Int) {
        
    }
    
    
}
