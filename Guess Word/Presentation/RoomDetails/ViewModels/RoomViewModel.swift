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
    private let repository = GuessWordApiRepository()
    
    @Published var loadingRoomError = false
    @Published var errorDescription: String? = nil
    
    @Published var roomModel: RoomModel? = nil
    
    @Published var guesses: [GuessData] = []
    
    @Published var isWordGuessed = false
    @Published var attemptsCount = 0
    @Published var fasterThan = 0
    
    func setup(roomCode: String) {
        self.roomCode = roomCode
    }
    
    func loadRoom() async {
        do {
            roomModel = try await repository.getRoomInfo(code: roomCode!)
        }
        catch {
            loadingRoomError = true
            errorDescription = ErrorUtil.getErrorDescription(error)
        }
    }
    
    func loadHistory() async {
        do {
            guesses = try await repository.getHistory(roomCode: roomCode!).map {
                GuessData(word: $0.word, order: $0.order)
            }
        }
        catch {
            errorDescription = ErrorUtil.getErrorDescription(error)
        }
    }
    
    func submitGuess(guess: String) async {
        do {
            let data = try await repository.submitGuess(
                roomCode: roomCode!,
                word: guess
            )
            
            if !data.alreadyGuessed! {
                guesses.append(GuessData(word: data.word, order: data.order))
                
                if (data.finishStat != nil) {
                    isWordGuessed = true
                    
                    attemptsCount = data.finishStat!.tryCount
                    fasterThan = Int(
                        (data.finishStat!.faster * 100).rounded()
                    )
                }
            }

        }
        catch {
            errorDescription = ErrorUtil.getErrorDescription(error)
        }
    }
}
