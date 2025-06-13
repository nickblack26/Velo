//
//  PSAManager.swift
//  Velo
//
//  Created by Nick Black on 6/9/25.
//
import Foundation

struct VeloManager {
    let baseUrl: URL = .init(string: "https://manage.velomethod.com/v4_6_release/apis/3.0")!
    let baseHeaders: [String: String] = [
        "clientId":ProcessInfo.processInfo.environment["CONNECT_WISE_CLIENT_ID"]!,
        "Authorization": "Basic " + "\(ProcessInfo.processInfo.environment["CONNECT_WISE_USERNAME"]!):\(ProcessInfo.processInfo.environment["CONNECT_WISE_PASSWORD"]!)".toBase64()
    ]
    let session = URLSession.shared
    
    static let shared = VeloManager()
    
    func getCompanies() async throws -> [Company] {
        var components = URLComponents(
            url: baseUrl.appendingPathComponent("/company/companies"),
            resolvingAgainstBaseURL: true
        )!
        
        components.queryItems = [
            .init(name: "conditions", value: "deletedFlag = false and status/id = 1"),
            .init(name: "childConditions", value: "types/id = 1"),
            .init(name: "orderBy", value: "identifier asc"),
            .init(name: "fields", value: "id,identifier,name,territory")
        ]
        
        guard let url = components.url else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = baseHeaders
        
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode([Company].self, from: data)
    }
    
    func getContacts() async throws -> [Contact] {
        var components = URLComponents(
            url: baseUrl.appendingPathComponent("/company/contacts"),
            resolvingAgainstBaseURL: true
        )!
        
        components.queryItems = [
            .init(name: "conditions", value: "company/id = 250 and inactiveFlag = false"),
            .init(name: "childConditions", value: "(types/id = 17 or types/id = 21)"),
            .init(name: "pageSize", value: "1000"),
            .init(name: "orderBy", value: "firstName")
        ]
        
        guard let url = components.url else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = baseHeaders
        
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode([Contact].self, from: data)
    }
    
    func getContact(id: Int) async throws -> Contact {
        let components = URLComponents(
            url: baseUrl.appendingPathComponent("/company/contacts/\(id)"),
            resolvingAgainstBaseURL: true
        )!
        
        guard let url = components.url else {
            fatalError("")
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = baseHeaders
        
        
        let (data, _) = try await session.data(for: request)
        return try JSONDecoder().decode(Contact.self, from: data)
    }
}
