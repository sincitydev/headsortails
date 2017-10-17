//
//  FirebaseManagerV2.swift
//  Heads or Tails
//
//  Created by Joshua Ramos on 10/15/17.
//  Copyright © 2017 Amanuel Ketebo. All rights reserved.
//

import Foundation
import Firebase

let DB_Base = Database.database().reference()

struct Literals {
    static let base = DB_Base
    static let users = DB_Base.child("users")
    static let games = DB_Base.child("games")
}

class FirebaseManagerV2 {
    static let instance = FirebaseManagerV2()
    
    // TODO - Create User
    func saveNewUser(_ player: Player) {
        let playerData = ["username": player.username,
                          "coins": player.coins] as [String : Any]
        
        Literals.users.child(player.uid).updateChildValues(playerData)
    }
    
    // TODO - Get Players
    func getPlayers(completion: @escaping (_ playersArray: [Player]) -> ()) {
        var playerArray = [Player]()
        
        Literals.users.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else { return }
            for snap in snapshot {
                if snap.key != Auth.auth().currentUser?.uid {
                    guard let username = snap.childSnapshot(forPath: "username").value as? String else { return }
                    guard let coins = snap.childSnapshot(forPath: "coins").value as? Int else { return }
                    let player = Player(uid: snap.key, username: username, coins: coins)
                    playerArray.append(player)
                }
            }
            DispatchQueue.main.async {
                completion(playerArray)
            }
        })
    }

   // TODO - Create Game for two players (uid, uid)
    func createGame(oppenentUID: String, initialBet: Int) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        getGameKeyWith(playerUID: userUID, playerUId: oppenentUID, completion: { (existingGame) in
            if existingGame == nil {
                let gamePlayers = [userUID: ["bet": initialBet], oppenentUID: ["bet": 0], "Status": "invite pending"] as [String : Any]
                
                Literals.games.childByAutoId().updateChildValues(gamePlayers)
            } else {
                print("Game already exists")
            }
        })
    }

    // function that returns the key for a specific game that contains the two players
    func getGameKeyWith(playerUID player1: String, playerUId player2: String, completion: @escaping (_ gameKey: String?)->()) {
        var gameKey: String? = nil
        Literals.games.observeSingleEvent(of: .value, with: { (gamesSnapshot) in
            guard let gamesSnapshot = gamesSnapshot.value as? [String: Any] else { completion(nil)
                return
            }
            gamesSnapshot.forEach({ (snap) in
                guard let gameDetails = snap.value as? [String: Any] else { completion(nil)
                    return
                }
                if gameDetails.keys.contains(player1) && gameDetails.keys.contains(player2) {
                    print("found")
                    gameKey = snap.key
                    completion(gameKey)
                    return
                }
            })
        })
    }
    
    func updateBet(forPlayerUID player: String, gameKey: String, bet: Int) {
        Literals.games.child(gameKey).observeSingleEvent(of: .value, with: { (gameSnapshot) in
            guard let gameSnapshot = gameSnapshot.value as? [String: Any] else { return }
            if gameSnapshot.keys.contains(player) {
                let bet = ["bet": bet]
                Literals.games.child(gameKey).child(player).updateChildValues(bet)
            }    
        })
    }
    
    // TODO - Get Games for players (uid)
    func getGames() {
        
    }
    
    // TODO - Get current currency
    func getCurrency(forPlayerUID player: String) {
        
    }
    
    // TODO - Update currecy for uid
    func updateCurrency(forPlayerUID player: String) {
        
    }
}
