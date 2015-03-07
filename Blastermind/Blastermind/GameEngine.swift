//
//  GameEngine.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.06.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation

// All logic and game moves should go through here.
// The engine may use other resources, locally or on a server, to make game
// decisions
class GameEngine {

    private var engineState = EngineState.Online(Client())

    private var serverConn = ServerConnection()

    private var playerCallback: (Match)->() = {(Match) in  }

    // DEBUG:
    func makeItAllHappen() {
        let maybePlayer = SuggestedPlayer(name: "Bobo")

        requestMatch(maybePlayer, startMatchCallback: mixItUp)
    }

    func mixItUp(Match) {
        println("What is even happening")
    }

    func weDidIt() {
        println("Winning.")
    }

    // Real stuff
    func requestMatch(player: SuggestedPlayer, startMatchCallback:(Match)->()) {
        switch engineState {
        case .Online(let theClient):
            playerCallback = startMatchCallback
//            theClient.startClient() // DEBUG:
            serverConn.requestNewMatch(player, callback: weDidIt)
        case .Offline:
            // start local match
            break
        }
    }
}

private enum EngineState {
    case Online(Client)
    case Offline
}