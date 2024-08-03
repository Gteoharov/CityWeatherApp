import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(Data, URLResponse), Error>
    
    func perform(request: URLRequest, queryItems: [URLQueryItem]?) async -> HTTPClientResult
}
