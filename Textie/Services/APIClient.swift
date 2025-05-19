//
//  APIClient.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

func sendRequestToServer(toEndpoint endpoint: String, httpMethod method: String, withToken token: String = "") async throws -> (Data, URLResponse) {
    guard let url = URL(string: endpoint) else {
        throw BackendError.badURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    let (responseData, response): (Data, URLResponse) = try await URLSession.shared.data(for: request)
    
    if let response = response as? HTTPURLResponse, response.statusCode >= 400 {
        throw BackendError.invalidResponse(statusCode: response.statusCode)
    }
    
    return (responseData, response)
}
