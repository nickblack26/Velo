import Foundation

protocol Searchable: Identifiable {
    var searchValue: String { get }
}

protocol Fetchable: Codable, Identifiable, Hashable {
    associatedtype Item: Identifiable, Codable = Self
    static var baseUrl: URL { get }
    static var baseHeaders: [String: String] { get }
    
    static var path: String { get }
    
    static var session: URLSession { get }
    static var sessionConfiguration: URLSessionConfiguration { get }
    
    /// Read functions
    static func getItems(queryItems: [URLQueryItem]?, showLog: Bool) async throws -> [Self]
    static func getItem(id: Item.ID) async throws -> Self
}

extension Fetchable {
    static var baseUrl: URL { .init(string: ProcessInfo.processInfo.environment["CONNECT_WISE_URL"]!)! }
    
    static var encodedAuth: String {
        "\(ProcessInfo.processInfo.environment["CONNECT_WISE_USERNAME"]!):\(ProcessInfo.processInfo.environment["CONNECT_WISE_PASSWORD"]!)".toBase64()
    }
    
    static var baseHeaders: [String: String] {
        [
            "clientId":ProcessInfo.processInfo.environment["CONNECT_WISE_CLIENT_ID"]!,
            "Authorization": "Basic " + encodedAuth
        ]
    }
    
    static var sessionConfiguration: URLSessionConfiguration {
        let config: URLSessionConfiguration = .default
        config.requestCachePolicy = .returnCacheDataElseLoad
        return config
    }
    
    static var session: URLSession { URLSession(configuration: sessionConfiguration) }
}

extension Fetchable {
    static func getItems(queryItems: [URLQueryItem]? = nil, showLog: Bool = false) async throws -> [Self] {
        var components = URLComponents(
            url: baseUrl.appendingPathComponent(path),
            resolvingAgainstBaseURL: true
        )!
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            return []
        }
        
        let request = getUrlRequest(for: url)
        
        let (data, _) = try await session.data(for: request)
        if showLog {
            print(String(data: data, encoding: .utf8))
        }
        return try JSONDecoder().decode([Self].self, from: data)
    }
    
    static func getItem(id: Item.ID) async throws -> Self {
        let components = URLComponents(
            url: baseUrl.appendingPathComponent(path + "/\(id)"),
            resolvingAgainstBaseURL: true
        )!
        
        guard let url = components.url else {
            fatalError("Could not build URL in getItem(id:) for \(Self.self)")
        }
        
        let request = getUrlRequest(for: url)
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
    static func getUrlRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = baseHeaders
        
        return request
    }
}


protocol Updatable: Fetchable {
    
}

protocol Creatable: Fetchable {
    static func create(data: Self) async throws -> Self
}

extension Creatable {
    static func create(data: Self) async throws -> Self {
        let components = URLComponents(
            url: baseUrl,
            resolvingAgainstBaseURL: true
        )!
        
        guard let url = components.url else {
            fatalError("Could not build URL in \(#function) for \(Self.self)")
        }
        
        var request = getUrlRequest(for: url)
        request.httpBody = try JSONEncoder().encode(data)
        
        let (data, _) = try await session.data(for: request)
        
        return try JSONDecoder().decode(Self.self, from: data)
    }
}

typealias Persistable = Fetchable & Updatable & Creatable
