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

let codeGuessKey = "code_pegs"
struct Guess {
    var codeGuess: [GuessType]

    // <3 <3 <3 <3 <3
    func asJSONDictionary() -> [String: [String]] {
        let stringlyGuesses = codeGuess.map {$0.rawValue}

        return [codeGuessKey: stringlyGuesses]
    }
    // 💕💕💕💕💕💕💕💕💕💕💕💕💕💕

}

//extension Guess {
//    init?(json: Dictionary)
//}

enum GuessType: String {
    case alpha = "alpha", beta = "beta", gamma = "gamma", delta = "delta", epsilon = "espilon", zeta = "zeta"

    func color() -> UIColor {
        switch self {
        case .alpha: return UIColor.alphaColor()
        case .beta: return UIColor.betaColor()
        case .gamma: return UIColor.gammaColor()
        case .delta: return UIColor.deltaColor()
        case .epsilon: return UIColor.epsilonColor()
        case .zeta: return UIColor.zetaColor()
        }
    }
}

extension GuessType {
    init?(oneIndex: Int) {
        let try: GuessType
        switch oneIndex {
        case 1:
            try = GuessType.alpha
        case 2:
            try = GuessType.beta
        case 3:
            try = GuessType.gamma
        case 4:
            try = GuessType.delta
        case 5:
            try = GuessType.epsilon
        case 6:
            try = GuessType.zeta
        default:
            return nil
        }
        self = try
    }
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

// MARK: Player related
let nameKey = "name"
let idKey = "id"
let guessesKey = "guesses"

struct SuggestedPlayer {
    var name: String

    func convertToRealPlayerWithID(id: Int) -> Player {
        return Player(name: self.name, id: id)
    }

    func asJSONDictionary() -> [String: [String: String]] { // soul dies a little
        return ["player": [nameKey: name]] // and a little more
    }
}

struct Player {
    var name: String
    var id: Int
    // var guesses: [Guess] // ignoring unless I need them
}

extension Player {
    init?(json: NSDictionary) {
        if let name = json[nameKey] as? String,
        let id = json[idKey] as? Int {
            self = Player(name: name, id: id)
        } else {
            return nil
        }
    }
}

struct Match {
    var channel: String
    var id: Int
    var name: String
//    var players: [Player]
    // var rounds: [Round] // not using this yet
    var state: MatchState
}

let channelKey = "channel"
let playersKey = "players"
// let roundsKey = "rounds
let stateKey = "state"
extension Match {
    init?(json: NSDictionary) {
        if let channel = json[channelKey] as? String,
            let id = json[idKey] as? Int,
            let name = json[nameKey] as? String,
//        let players = json[playersKey] as? [Any],
            let stateString = json[stateKey] as? String,
            let state = MatchState(rawValue: stateString)// MatchState
        {
            self = Match(channel: channel, id: id, name: name, state: state)
        } else {
            return nil
        }
    }
}

enum MatchState: String {
    case MatchMaking = "match_making", InProgress = "in_progress", finished = "finished"
}
