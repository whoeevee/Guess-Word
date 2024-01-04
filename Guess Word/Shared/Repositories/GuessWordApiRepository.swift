//
//  GuessWordApiRepository.swift
//  Guess Word
//
//  Created by eevee on 04/01/2024.
//

import Foundation

class GuessWordApiRepository: GuessWordRepository {
    
    private let dataSource = GuessWordApiDataSource()
    
    func getRoomInfo(code: String) async throws -> RoomModel {
        return try await dataSource.getRoomInfo(code: code)
    }
    
    func getHistory(roomCode: String) async throws -> [GuessResponse] {
        return try await dataSource.getHistory(roomCode: roomCode)
    }
    
    func submitGuess(roomCode: String, word: String) async throws -> GuessResponse {
        return try await dataSource.submitGuess(roomCode: roomCode, word: word)
    }
}
