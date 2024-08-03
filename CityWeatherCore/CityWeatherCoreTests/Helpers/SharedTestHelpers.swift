import Foundation

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func createURLRequest() -> URLRequest {
    URLRequest(url: anyURL())
}

func nonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func buildURL(with query: String, url: URL) -> URL {
    url.appending(queryItems: [URLQueryItem(name: "kv", value: query)])
}

func createQuery() -> String {
    "Paris"
}
