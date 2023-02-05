import Foundation

protocol NewsListNetworkService: AnyObject {
    func getNews(
        page: Int,
        completion: @escaping (Result<NetworkModel, Error>) -> Void
    )
}

final class NewsListNetworkServiceImp: NewsListNetworkService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func getNews(
        page: Int,
        completion: @escaping (Result<NetworkModel, Error>) -> Void
    ) {
        guard let request = try? createNewsListRequest(page: page)
        else {
            completion(.failure(HTTPError.decodingFailed))
            return
        }

        networkClient.processRequest(request: request, completion: completion)
    }

    private func createNewsListRequest(page: Int) throws -> HTTPRequest {
        
        let appendingUrlString = "/everything"
        let headers = ["X-Api-Key": GlobalConstants.apiKey]
        let params: [HTTPRequestQueryItem] = [("pageSize", String(GlobalConstants.pageSize)),
                                              ("domains", GlobalConstants.domains),
                                               ("page", String(page))]
        
        return HTTPRequest(
            route: GlobalConstants.baseUrl + appendingUrlString,
            headers: headers,
            queryItems: params,
            httpMethod: .get
        )
    }
}
