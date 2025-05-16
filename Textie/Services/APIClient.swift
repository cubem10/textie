//
//  APIClient.swift
//  Textie
//
//  Created by 하정우 on 5/16/25.
//

import Foundation

func sendRequestToServer(toEndpoint endpoint: String, httpMethod method: String, withCredential credential: Credential = Credential(username: "", password: "")) async throws -> (Data, URLResponse) {
    guard let url = URL(string: endpoint) else {
        throw BackendError.badURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    do {
        let (responseData, response): (Data, URLResponse) = try await URLSession.shared.data(for: request)
        return (responseData, response)
    } catch {
        print("An error occurred while processing the request: \(error)")
    }
    
    return (Data(), URLResponse())
}
