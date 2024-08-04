import Foundation

public final class URLSessionClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func perform(request: URLRequest, queryItems: [URLQueryItem]?) async -> HTTPClient.HTTPClientResult {
        do {
            let (data, response) = try await session.data(for: RequestBuilder.buildRequest(from: request, with: queryItems))
            if let response = response as? HTTPURLResponse {
                return .success((data, response))
            }
            return .failure(HTTPClientError.unexpectedResponse)
        } catch {
            let nsError = error as NSError
            return .failure(HTTPClientError.networkError(nsError.code, nsError.localizedDescription))
        }
    }
}
