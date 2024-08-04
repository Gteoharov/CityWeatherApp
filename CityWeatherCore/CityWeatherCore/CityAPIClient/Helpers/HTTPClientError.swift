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
        case let (.networkError(firstCodeError, firstMessageError), .networkError(secondCodeError, secondMessageError)):
            return firstCodeError == secondCodeError && firstMessageError == secondMessageError
        default:
            return false
        }
    }
}
