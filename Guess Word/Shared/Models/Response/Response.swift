//
//  Response.swift
//  Guess Word
//
//  Created by eevee on 25/07/2023.
//

import Foundation

struct FinishStat: Codable {
    var tryCount: Int
    var faster: Double
}

class GuessResponse: Codable {
    var word: String
    var order: Int
    var alreadyGuessed: Bool?
    var finishStat: FinishStat?
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        word = try values.decode(String.self, forKey: .word)
        order = try values.decode(Int.self, forKey: .order)
        alreadyGuessed = try? values.decode(Bool.self, forKey: .alreadyGuessed)
        finishStat = try? values.decode(FinishStat.self, forKey: .finishStat)
    }
}

struct GuessErrorResponse: Codable {
    var detail: String
    var errorCode: String
}
