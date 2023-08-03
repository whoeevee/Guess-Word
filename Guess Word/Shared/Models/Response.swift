//
//  Response.swift
//  Guess Word
//
//  Created by eevee on 25/07/2023.
//

import Foundation

struct FinishStat: Codable {
    var try_count: Int
    var faster: Double
}

class GuessResponse: Codable {
    var word: String
    var order: Int
    var already_guessed: Bool?
    var finish_stat: FinishStat?
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        word = try values.decode(String.self, forKey: .word)
        order = try values.decode(Int.self, forKey: .order)
        already_guessed = try? values.decode(Bool.self, forKey: .already_guessed)
        finish_stat = try? values.decode(FinishStat.self, forKey: .finish_stat)
    }
}

struct GuessErrorResponse: Codable {
    var detail: String
    var error_code: String
}
