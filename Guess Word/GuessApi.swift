//
//  GuessApi.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import Foundation
 
class GuessApi {
    
    var djangoSessionId: String
    
    private func perform<body: Encodable>(path: String, method: String, body: body) async throws -> Data {
        
        var request = URLRequest(url: URL(string: "\(Constants.ApiUrl)\(path)")!)
        
        request.httpMethod = method
        request.addValue("django_session_id=\(djangoSessionId)", forHTTPHeaderField: "Cookie")
        
        if method == "POST" {
            let httpBody = try! JSONEncoder().encode(body)
            
            request.httpBody = httpBody
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, _) = try! await URLSession.shared.data(for: request)
        
        if let error = try? JSONDecoder().decode(GuessErrorResponse.self, from: data) {
            throw GuessException.requestException(code: error.error_code, detail: error.detail)
        }
        
        return data
    }
    
    init(djangoSessionId: String) {
        self.djangoSessionId = djangoSessionId
    }
    
    func getRoomInfo(code: String) async throws -> Room {
        return try JSONDecoder().decode(
           Room.self,
           from: await perform(
               path: "/rooms/\(code)/",
               method: "GET",
               body: Empty()
           )
       )
    }
    
    func getHistory(roomCode: String) async throws -> [GuessResponse] {
        return try JSONDecoder().decode(
        [GuessResponse].self,
           from: await perform(
               path: "/rooms/\(roomCode)/history",
               method: "GET",
               body: Empty()
           )
       )
    }
    
    func submitGuess(roomCode: String, word: String) async throws -> GuessResponse {
        return try JSONDecoder().decode(
            GuessResponse.self,
            from: await perform(
                path: "/rooms/\(roomCode)/guess/",
                method: "POST",
                body: GuessRequest(word: word)
            )
        )
    }
}
