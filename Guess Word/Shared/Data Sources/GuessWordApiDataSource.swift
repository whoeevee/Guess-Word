//
//  GuessWordApiDataSource.swift
//  Guess Word
//
//  Created by eevee on 04/01/2024.
//

import Foundation


class GuessWordApiDataSource: GuessWordDataSource {
    
    private let djangoSessionId = UserPreferences.shared.djangoSessionId()
    private let apiUrl: String = "https://guess-word.com/api"
    
    private func decodeFromSnakeCase<T>(
        _ type: T.Type,
        from data: Data
    ) throws -> T where T : Decodable {
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(type, from: data)
    }
    
    private func perform(_ path: String, body: Data? = nil) async throws -> Data {
        
        var request = URLRequest(url: URL(string: "\(apiUrl)\(path)")!)
        
        request.httpMethod = body == nil ? "GET" : "POST"
        request.addValue("django_session_id=\(djangoSessionId!)", forHTTPHeaderField: "Cookie")
        
        if body != nil {
            request.httpBody = body
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, _) = try! await URLSession.shared.data(for: request)
        
        if let error = try? decodeFromSnakeCase(GuessErrorResponse.self, from: data) {
            throw GuessError.RequestError(code: error.errorCode, detail: error.detail)
        }
        
        return data
    }
    
    func getRoomInfo(code: String) async throws -> RoomModel {
        return try decodeFromSnakeCase(
           RoomModel.self,
           from: await perform("/rooms/\(code)/")
       )
    }
    
    func getHistory(roomCode: String) async throws -> [GuessResponse] {
        return try decodeFromSnakeCase(
            [GuessResponse].self,
            from: await perform(
               "/rooms/\(roomCode)/history/"
            )
       )
    }
    
    func submitGuess(roomCode: String, word: String) async throws -> GuessResponse {
        return try decodeFromSnakeCase(
            GuessResponse.self,
            from: await perform(
                "/rooms/\(roomCode)/guess/",
                body: try JSONEncoder().encode(GuessRequest(word: word))
            )
        )
    }
}
