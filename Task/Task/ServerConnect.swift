//
//  ServerConnect.swift
//  Task
//
//  Created by Jagdish Jangir on 28/05/24.
//

import Foundation

class ServerConnect {
    
    private let url = "https://jsonplaceholder.typicode.com/posts?_page={CurrentPage}&_limit={limit}"
    
    static let shared = ServerConnect()
    
    private init() {}
    
    func fetchData(page: UInt, postLimit: UInt) async throws -> [ListItem] {
    
        guard let url = URL(string: self.url.replacingOccurrences(of: "{CurrentPage}", with: "\(page)").replacingOccurrences(of: "{limit}", with: "\(postLimit)")) else {
            return []
        }
        
        let urlRequest = URLRequest(url: url)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            let result = try JSONDecoder().decode([ListItem].self, from: data)
            return result
        }catch {
            throw error
        }
        
    }
    
}
