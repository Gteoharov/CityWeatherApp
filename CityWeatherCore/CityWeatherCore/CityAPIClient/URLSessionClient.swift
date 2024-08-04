import Foundation

public final class URLSessionClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func perform(request: URLRequest, queryItems: [URLQueryItem]?) async -> HTTPClient.HTTPClientResult {
        do {
            let (data, response) = try await session.data(for: buildRequest(from: request, with: queryItems))
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

private extension URLSessionClient {
    private func buildRequest(from request: URLRequest, with queryItems: [URLQueryItem]?) throws -> URLRequest {
        guard var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            throw HTTPClientError.invalidURL
        }
        
        if let existingItems = components.queryItems {
            components.queryItems = existingItems + (queryItems ?? [])
        } else if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw HTTPClientError.invalidURL
        }
        
        var newRequest = request
        newRequest.url = url
        return newRequest
    }
}
