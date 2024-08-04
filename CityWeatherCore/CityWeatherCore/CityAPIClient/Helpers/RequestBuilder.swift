import Foundation

public final class RequestBuilder {
    public static func buildRequest(from request: URLRequest, with queryItems: [URLQueryItem]?) throws -> URLRequest {
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
