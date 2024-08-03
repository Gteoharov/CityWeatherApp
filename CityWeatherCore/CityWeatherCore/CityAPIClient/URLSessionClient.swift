import Foundation

public final class URLSessionClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private enum Error: Swift.Error {
        case invalidURL
        case unexpectedResponse
    }
    
    public func perform(request: URLRequest, queryItems: [URLQueryItem]?) async -> HTTPClient.HTTPClientResult {
        do {
            let (data, response) = try await session.data(for: request)
            if let response = response as? HTTPURLResponse {
                return .success((data, response))
            }
            return .failure(Error.unexpectedResponse)
        } catch {
            return .failure(error)
        }
    }
}

private extension URLSessionClient {
    private func buildRequest(from request: URLRequest, with queryItems: [URLQueryItem]?) throws -> URLRequest {
        guard var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            throw Error.invalidURL
        }
        
        if let existingItems = components.queryItems {
            components.queryItems = existingItems + (queryItems ?? [])
        } else if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        guard let url = components.url else {
            throw Error.invalidURL
        }
        
        var newRequest = request
        newRequest.url = url
        return newRequest
    }
}
