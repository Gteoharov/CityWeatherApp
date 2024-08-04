import Foundation


func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    Data("any data".utf8)
}

func createEmptyListJSONData() -> Data {
    Data("[]".utf8)
}

func createURLRequest() -> URLRequest {
    URLRequest(url: anyURL())
}

func createURLQuerryItemArray(for query: String) -> [URLQueryItem] {
    [URLQueryItem(name: "k", value: query)]
}

func create200StatusCode() -> Int {
    200
}

func createStatusCodesArray() -> [Int] {
    [199, 201, 300, 400, 500]
}

func createQuery() -> String {
    "Paris"
}

func nonHTTPURLResponse() -> URLResponse {
    URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
}

func anyHTTPURLResponse() -> HTTPURLResponse {
    HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}

func buildURL(with query: String, url: URL) -> URL {
    url.appending(queryItems: [URLQueryItem(name: "q", value: query)])
}


