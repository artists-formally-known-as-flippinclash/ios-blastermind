//
//  GameModels.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.06.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

struct Guess {
    var codeGuess: [Int]
}

struct Feedback {
    let key: [KeyType] // should this just be count of each type instead?
}

enum KeyType {
    case CorrectType, CorrectTypeAndPosition
}

enum PegTypeOption {
    case Color(UIColor), Shape(SKShapeNode), Number(Int)
}

enum RoundStatus {
    case Waiting, InProgress, Won, Lost, Broken
}

// Enum is probably wrong type here, since there might be more or less than 6
//enum PegType: PegTypeOption { // T == PegTypeOption
//    case A(PegTypeOption), B(PegTypeOption), C(PegTypeOption), D(PegTypeOption), E(PegTypeOption), F(PegTypeOption)
//}

struct SuggestedPlayer {
    var name: String

    func convertToRealPlayerWithID(id: Int) -> Player {
        return Player(name: self.name, id: id)
    }

    func asJSONDictionary() -> [String: [String: String]] { // soul dies a little
        return ["player": ["name": name]] // and a little more
    }
}

struct Player {
    var name: String
    var id: Int
}

struct Match {
    var id: Int
    var channel: String
    var state: MatchState
    var players: [Player] // self(Player) will be the last one in the list from first return of match
}

enum MatchState: String {
    case MatchMaking = "match-making", InProgress = "in-progress", finished = "finished"
}