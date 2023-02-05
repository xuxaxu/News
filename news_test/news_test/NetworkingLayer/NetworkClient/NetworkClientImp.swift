import Foundation

struct NetworkClientImp: NetworkClient {
    // MARK: - Properties

    private let urlSession: URLSession

    // MARK: - Lifecycle

    init(urlSession: URLSession) {
        self.urlSession = urlSession
        urlSession.configuration.timeoutIntervalForRequest = Constants.timeout
    }

    // MARK: - Public

    @discardableResult
    func processRequest<T: Decodable>(
        request: HTTPRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> Cancellable? {
        do {
            let urlRequest = try createUrlRequest(from: request)

            let task = urlSession.dataTask(with: urlRequest) { data, response, _ in
                guard let response = response as? HTTPURLResponse,
                      let data = data,
                      let stringData = String(data: data, encoding: .utf8)
                else {
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(HTTPError.failedResponseUnwrapping))
                    }

                    return
                }

                let unwrappedData = Data(stringData.utf8)
                let handledResponse = HTTPNetworkResponse.handleNetworkResponse(for: response)

                switch handledResponse {
                case .success:
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = request.keyDecodingStrategy
                    jsonDecoder.dateDecodingStrategy = request.dateDecodingStrategy

                    do {
                        let result = try jsonDecoder.decode(T.self, from: unwrappedData)
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.success(result))
                        }
                    } catch {
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.failure(error))
                        }
                    }
                case let .failure(error):
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(error))
                    }
                }
            }

            task.resume()
            return task
        } catch {
            NetworkClientImp.executeCompletionOnMainThread {
                completion(.failure(HTTPError.failed))
            }
        }

        return nil
    }
    
    @discardableResult
    func rawDataRequest(request: URLRequest,
                        completion: @escaping (Result<Data, Error>) -> Void) -> Cancellable? {
        
            let task = urlSession.dataTask(with: request) { data, response, _ in
                guard let response = response as? HTTPURLResponse,
                      let data = data
                else {
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(HTTPError.failedResponseUnwrapping))
                    }

                    return
                }

                let handledResponse = HTTPNetworkResponse.handleNetworkResponse(for: response)

                switch handledResponse {
                case .success:
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.success(data))
                        }
                case let .failure(error):
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(error))
                    }
                }
            }

            task.resume()
            return task
    }

    // MARK: - Private

    private func createUrlRequest(from request: HTTPRequest) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: request.route) else {
            throw HTTPError.missingURL
        }

        let queryItems = request.queryItems.map { query in
            URLQueryItem(name: query.key, value: query.value)
        }

        urlComponents.queryItems = queryItems
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(
            of: Constants.replaceOccurrencesOf,
            with: Constants.replacingOccurrencesWith
        )

        guard let url = urlComponents.url
        else {
            throw HTTPError.missingURLComponents
        }

        var generatedRequest: URLRequest = .init(url: url)
        generatedRequest.httpMethod = request.httpMethod.rawValue
        generatedRequest.httpBody = request.body

        request.headers.forEach {
            generatedRequest.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        return generatedRequest
    }

    private static func executeCompletionOnMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async {
            closure()
        }
    }
}

extension URLSessionDataTask: Cancellable {}

// MARK: - Nested types

extension NetworkClientImp {
    enum Constants {
        static let replaceOccurrencesOf: String = "+"
        static let replacingOccurrencesWith: String = "%2B"
        static let timeout: Double = 30.0
    }
}
