//
//  Internal.swift
//  Guess Word
//
//  Created by eevee on 25/07/2023.
//

import Foundation

struct GuessData: Identifiable, Equatable {
    let id = UUID()
    var word: String
    var order: Int
}
