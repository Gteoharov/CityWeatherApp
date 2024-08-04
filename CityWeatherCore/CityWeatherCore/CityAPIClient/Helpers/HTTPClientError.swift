import Foundation

public enum HTTPClientError: Error, Equatable {
    case invalidURL
    case unexpectedResponse
    case networkError(Int, String)
    
    public static func == (lhs: HTTPClientError, rhs: HTTPClientError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.unexpectedResponse, .unexpectedResponse):
            return true
        case let (.networkError(code1, message1), .networkError(code2, message2)):
            return code1 == code2 && message1 == message2
        default:
            return false
        }
    }
}
