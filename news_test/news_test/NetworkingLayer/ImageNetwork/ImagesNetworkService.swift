import Foundation
import UIKit

protocol ImagesNetworkService: AnyObject {
    func getImage(
        url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}

final class ImagesNetworkServiceImp: ImagesNetworkService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func getImage(
        url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        let request = URLRequest(url: url)

        networkClient.rawDataRequest(request: request) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    completion(.success(image))
                } else {
                    completion(.failure(HTTPError.decodingFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

