//
//  UserPreferences.swift
//  Guess Word
//
//  Created by eevee on 24/07/2023.
//

import Foundation

struct UserPreferences {
    
    static let shared = UserPreferences()
    let userDefaults = UserDefaults.standard
    
    private init() { }
    
    func djangoSessionId() -> String? {
        return UserDefaults.standard.string(forKey: "djangoSessionId")
    }
    
    func updateDjangoSessionId(sessionId: String) {
        UserDefaults.standard.set(sessionId, forKey: "djangoSessionId")
    }
}
