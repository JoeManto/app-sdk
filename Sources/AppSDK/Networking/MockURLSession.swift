//
//  MockURLSession.swift
//  PrefCLI
//
//  Created by Joe Manto on 12/18/25.
//

import Foundation

public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// `MockURLSession` is a mock implementation of the `URLSessionProtocol` protocol.
/// It is primarily intended for use in unit tests or previews, where actual network calls should be avoided.
/// 
/// This structure allows you to specify a mapping of endpoint URL substrings to `Data` objects representing mock responses.
///
/// {
///   "domain.com/example": {
///      "foo": "bar"
///   }
/// }
///
/// Consider setting and using `URLSession.appSession`for all requests to allow easy switching between real requests and mock requests.
public struct MockURLSession: URLSessionProtocol {
    private var _endpointResponses: [URL: Any]

    public init(endpointResponses: [URL: Any]) {
        self._endpointResponses = endpointResponses
    }

    public init(fileURL: URL) throws {
        let path: String
        if #available(macOS 13.0, *) {
            path = fileURL.path(percentEncoded: false)
        } else {
            guard let filePath = fileURL.path.removingPercentEncoding else {
                throw AppError.invalidInput("Invalid file URL")
            }
            path = filePath
        }

        guard let content = FileManager.default.contents(atPath: path) else {
            throw AppError.invalidInput("Failed to read mock data file")
        }

        guard let jsonResponses = try JSONSerialization.jsonObject(with: content, options: []) as? [String: Any] else {
            throw AppError.invalidInput("Failed to parse mock data file as JSON")
        }

        var jsonURLResponses: [URL: Any] = [:]
        for responseURLString in jsonResponses.keys {
            guard let url = URL(string: responseURLString) else {
                continue
            }
            jsonURLResponses[url] = jsonResponses[responseURLString]
        }

        _endpointResponses = jsonURLResponses
    }

    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        let makeMatchableURL: (URL?) -> URL? = { url in
            guard let url else {
                return nil
            }
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            components?.queryItems?.removeAll()
            components?.scheme = nil
            return components?.url
        }

        guard let url = makeMatchableURL(request.url) else {
            throw URLError(.badURL)
        }

        guard let mockResponse = _endpointResponses.first(where: {
            request.url?.absoluteString.contains($0.key.absoluteString) ?? false
            //makeMatchableURL($0.key.absoluteURL) == url
        })?.value else {
            throw AppError.notFound(resource: "Mocked endpoint response", url.absoluteString)
        }

        let data = try JSONSerialization.data(withJSONObject: mockResponse)

        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: data.count, textEncodingName: nil)
        return (data, response)
    }
}

public extension URLSession {
    public static var appSession: URLSessionProtocol = URLSession.shared
}
