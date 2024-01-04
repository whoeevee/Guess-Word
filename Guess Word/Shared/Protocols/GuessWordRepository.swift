//
//  GuessWordRepository.swift
//  Guess Word
//
//  Created by eevee on 04/01/2024.
//

import Foundation

protocol GuessWordRepository {
    func getRoomInfo(code: String) async throws -> RoomModel
    func getHistory(roomCode: String) async throws -> [GuessResponse]
    func submitGuess(roomCode: String, word: String) async throws -> GuessResponse
}
