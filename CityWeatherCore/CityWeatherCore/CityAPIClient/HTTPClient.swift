import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
    
    func perform(request: URLRequest, queryItems: [URLQueryItem]?) async -> HTTPClientResult
}
