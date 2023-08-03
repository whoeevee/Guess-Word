//
//  RoomViewModel.swift
//  Guess Word
//
//  Created by eevee on 02/08/2023.
//

import Foundation
import SwiftUI

@MainActor final class RoomViewModel: ObservableObject {

    var roomCode: String? = nil
    var guessApi: GuessApi? = nil
    
    @Published var roomModel: RoomModel? = nil
    
    @Published var guesses: [GuessData] = []
    
    @Published var errorCode: String? = nil
    @Published var errorDetail: String? = nil
    
    @Published var isWordGuessed = false
    @Published var attemptsCount = 0
    @Published var fasterThan = 0
    
    func setup(roomCode: String) {
        self.roomCode = roomCode
        self.guessApi = GuessApi(
            djangoSessionId: UserPreferences.shared.djangoSessionId()!
        )
    }
    
    private func loadRoom() async throws {
        roomModel = try await guessApi!.getRoomInfo(code: roomCode!)
    }
    
    private func loadHistory() async throws {
        guesses = try await guessApi!.getHistory(roomCode: roomCode!).map {
            GuessData(word: $0.word, order: $0.order)
        }
    }
    
    func loadRoomAndHistory() async {
        do {
            try await loadRoom()
            try await loadHistory()
        }
        catch {
            errorCode = "loading_room_error"
            errorDetail = "loading_room_error".localized
        }
    }
    
    func submitGuess(guess: String) async {
        do {
            let data = try await guessApi!.submitGuess(
                roomCode: roomCode!,
                word: guess
            )
            
            if (!data.already_guessed!) {
                guesses.append(GuessData(word: data.word, order: data.order))
                
                if (data.finish_stat != nil) {
                    isWordGuessed = true
                    
                    attemptsCount = data.finish_stat!.try_count
                    fasterThan = Int(
                        (data.finish_stat!.faster * 100).rounded()
                    )
                }
            }

        }
        catch GuessException.requestException(let code, let detail) {
            errorCode = code
            
            let localizedDetail = errorCode!.localized
            
            errorDetail = localizedDetail == errorCode
                ? detail
                : localizedDetail
        }
        catch {
            errorCode = "unknown_error"
            errorDetail = "unknown_error_occurred".localized
        }
    }
}
