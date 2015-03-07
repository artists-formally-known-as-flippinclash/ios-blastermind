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
class GameEngine: ClientDelegate {

    private var engineState = EngineState.Online(Client())

    private var serverConn = ServerConnection()

    private var playerCallback: (Match)->() = {(Match) in  }

    var localPlayer: Player = Player(name:"Bobo", id: 1)

    var watchedMatch: Match?

    // aaaaaaahhhh
    var feedbackForAllRows: [Feedback] = []

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
            theClient.delegate = self
            playerCallback = startMatchCallback
            serverConn.requestNewMatch(player, callback: receiveMatch)
        case .Offline:
            // start local match
            break
        }
    }

    func receiveMatch(data: NSData) {
        let meDictKey = "you"
        let dataDictKey = "data"

        var jsonParsingError = NSErrorPointer()
        let matchDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: jsonParsingError) as! [String: AnyObject]?
        if matchDict == nil && jsonParsingError != nil {
            println("Failed to parse match: <\(jsonParsingError)")
        } else if let actualMatch = matchDict,
            let me = actualMatch[meDictKey] as? NSDictionary,
            let player = Player(json: me),
            let data = actualMatch[dataDictKey] as? NSDictionary,
            let match = Match(json: data)
             {
//                println("Received player: <\(player)>, match: <\(match)>, name: <\(match.name)>")
                localPlayer = player
                switch engineState {
                case .Online(let client):
                    watchedMatch = match
                    client.watchMatch(match, callback: { (eventData) -> Void in
                        println("engine got data: <\(eventData)>")
                    })
                case .Offline:
                    break
                }
        }
    }

    func receivedEvent(_: PTPusherEvent!) {
        playerCallback(watchedMatch!)
    }

    func easyGuess(guess: Guess) {
        sendInGuess(localPlayer, match: watchedMatch!, guess: guess)
    }

    func sendInGuess(player: Player, match: Match, guess: Guess) {
        serverConn.actuallySubmitGuess(player, match: match, guess: guess) { (data) -> () in
            println("got guess data: <\(data)>")
            self.receiveFeedback(data)
        }
    }

    func receiveFeedback(data: NSData) {
        let dataDictKey = "data"
        let feedbackDictKey = "feedback"
        let typeCountKey = "position_count"
        let typeAndPositionKey = "peg_count"

        let outcomeKey = "outcome" // might cheat and grab this
        let lossKey = "incorrect"
        let winKey = "correct"

        var jsonParsingError = NSErrorPointer()
        let fullFeedbackDict = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: jsonParsingError) as! [String: AnyObject]?
        if fullFeedbackDict == nil && jsonParsingError != nil {
            println("Failed to parse match: <\(jsonParsingError)")
        } else if let actualDict = fullFeedbackDict,
            let dataDict = actualDict[dataDictKey] as? NSDictionary,
        let feedbackDict = dataDict[feedbackDictKey] as? [String: Int] {
                println(fullFeedbackDict)
                println(feedbackDict)
                let tc = feedbackDict[typeCountKey] ?? 0
                let tpc = feedbackDict[typeAndPositionKey] ?? 0
                let feedback = Feedback(typeCount: tc, typeAndPositionCount: tpc, row: 0) // FIXME: BROKEN, NEED ROW
        }

    }
}

private enum EngineState {
    case Online(Client)
    case Offline
}