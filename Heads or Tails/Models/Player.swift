//
//  Player.swift
//  Heads or Tails
//
//  Created by Amanuel Ketebo on 8/29/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation

class Player {
    var uid: String
    var username: String
    var coins: Int
    var online: Bool
    
    init(uid: String, username: String, coins: Int, online: Bool) {
        self.uid = uid
        self.username = username
        self.coins = coins
        self.online = online
    }
}

extension Player {
    convenience init?(uid: String, _ firebaseJSON: [String: Any]) {
        if let username = firebaseJSON[DatabaseKeys.username.rawValue] as? String,
            let coins = firebaseJSON[DatabaseKeys.coins.rawValue] as? Int,
            let online = firebaseJSON[DatabaseKeys.online.rawValue] as? Bool {
            self.init(uid: uid, username: username, coins: coins, online: online)
        }
        else {
            return nil
        }
    }
}

