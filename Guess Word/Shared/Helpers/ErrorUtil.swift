//
//  ErrorUtil.swift
//  Guess Word
//
//  Created by eevee on 04/01/2024.
//

import Foundation

struct ErrorUtil {
    
    static func getErrorDescription(_ error: Swift.Error) -> String {
        
        switch error {
            
        case let guessError as GuessError:
            return guessError.description
            
        case let urlError as URLError:
            return urlError.localizedDescription
            
        default:
            return String(describing: error)
            
        }
    }
}
