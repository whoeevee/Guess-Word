//
//  Exception.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import Foundation

enum GuessException: Swift.Error {
    case requestException(code: String, detail: String)
}
