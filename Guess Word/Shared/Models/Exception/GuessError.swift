//
//  Exception.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import Foundation

enum GuessError: Swift.Error {
    
    case RequestError(code: String, detail: String)
    
    var description: String {
        
        switch self {
            
        case .RequestError(let code, let detail):
            
            let errorCode = code
            let localizedDetail = errorCode.localized
            
            return localizedDetail == errorCode
                ? detail
                : localizedDetail
        }
    }
}
