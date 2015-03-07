//
//  Server.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.05.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

protocol ClientDelegate: class {
    func receivedEvent(PTPusherEvent!)
}

let matchStartEvent = "match-started"
let matchEndEvent = "match-ended"
//let matchProgressEvent = "match-progress" // not using

class Client: NSObject, PTPusherDelegate {
    lazy var client: PTPusher = {
        return PTPusher.pusherWithKey("a8dc613841aa8963a8a4", delegate: self) as! PTPusher
    }()

    var gameChannel: PTPusherChannel?
    weak var delegate: ClientDelegate?

    // DEBUG:
    func startClientDebug() {
        self.client.connect()
        let gameChannel = self.client.subscribeToChannelNamed("game-us")
        gameChannel.bindToEventNamed("match-started", handleWithBlock: {
            eventData in
            self.ping(eventData)
        })
        self.gameChannel = gameChannel
    }
    func ping(event: PTPusherEvent) {
        println("ping: <\(event)>")
    }

    // Client Goodness

    func watchMatch(match: Match, callback: PTPusherEventBlockHandler) {
        self.client.connect()
        let gameChannel = self.client.subscribeToChannelNamed(match.channel)
        gameChannel?.bindToEventNamed(matchStartEvent, handleWithBlock: {
            eventData in
            self.ping(eventData)
            self.sendToDelegate(eventData)
        })
        gameChannel?.bindToEventNamed(matchEndEvent, handleWithBlock: {
            eventData in
            self.ping(eventData)
            self.sendToDelegate(eventData)
            gameChannel?.unsubscribe()
//            self.gameChannel = nil
            self.client.disconnect()
        })
    }

    func sendToDelegate(eventData: PTPusherEvent!) {
        if let watchWatcher = self.delegate {
            watchWatcher.receivedEvent(eventData)
        }
    }

}

class ServerConnection {
    let baseString = "http://api.blasterminds.com/"
    let fakeGuessURL = NSURL(string:"http://private-73307-blastermind.apiary-mock.com/matches/801/guesses")!

    lazy var session: NSURLSession = {
        return NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    }()

    func requestNewMatch(player: SuggestedPlayer, callback: (NSData)->() ) {
        let req = createMatchRequest(player)
//        println("<\(req.allHTTPHeaderFields)>, <\(req.HTTPBody)>")
        let matchTask = session.dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            println("response: <\(response)>, <\(error)>")

            if let actualData = data {
                callback(actualData)
            } else {
                println("Error. Error!!!11: <\(error)>")
            }
        })

        matchTask.resume()
    }

    func actuallySubmitGuess(player: Player, match: Match, guess: Guess, callback: (NSData)->() ) {
        let req = createGuessRequest(player, match: match, guess: guess)
//        println("<\(__FUNCTION__):\(req.allHTTPHeaderFields)>, <\(req.HTTPBody)>")
        let guessTask = session.dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            println("response: <\(response)>, <\(error)>")

        })
        guessTask.resume()
    }

    // MARK: Convenience request builders
    func createMatchRequest(player: SuggestedPlayer) -> NSURLRequest {
        let request = mutableRequestForURL(requestMatchURL()!) // BOOM not Swifty
        let payload = player.asJSONDictionary()

        var maybeError = NSErrorPointer()
        let data = NSJSONSerialization.dataWithJSONObject(payload, options: nil, error: maybeError)
        if data == nil && maybeError != nil {
            // tell somebody
            println("Oops. Broken request with no data. <\(maybeError)>")
        } else if let actualData = data {
            request.HTTPBody = actualData
        }

        return request.copy() as! NSURLRequest
    }

    let guessDictKey = "guess"
    func createGuessRequest(player: Player, match: Match, guess: Guess) -> NSURLRequest {
        let request = mutableRequestForURL(guessURL(player, match: match)!)
        let guessDict = guess.asJSONDictionary()
        let payload = [guessDictKey: guessDict]

        var maybeError = NSErrorPointer()
        let data = NSJSONSerialization.dataWithJSONObject(payload, options: nil, error: maybeError)
        if data == nil && maybeError != nil {
            println("Oops. Broken request with no data. <\(maybeError)>")
        } else if let actualData = data {
            request.HTTPBody = actualData
        }

        return request.copy() as! NSURLRequest
    }

    // MARK: Request creation
    func mutableRequestForURL(url: NSURL) -> NSMutableURLRequest {
        var mutableRequest = NSMutableURLRequest(URL: url)
        mutableRequest.HTTPMethod = "POST"
        mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return mutableRequest
    }

    // MARK: URL Creation
    func fullURLForEndpoint(endpoint: String) -> NSURL? {
        // escaping? Who ever heard of it.
        let fullString = baseString.stringByAppendingString("\(endpoint)")
        let fullURL = NSURL(string: fullString)
        return fullURL
    }

    // MARK: convenience urls
    let createMatchString = "matches"
    func requestMatchURL() -> NSURL? {
        return fullURLForEndpoint(createMatchString)
    }

    func guessURL(player: Player, match: Match) -> NSURL? {
        var endpoint = "matches/\(match.id)/players/\(player.id)/guesses"
        return fullURLForEndpoint(endpoint)
    }

    func guess([Int], result:([Int]) -> ()) {
        let guessTask = session.dataTaskWithURL(fakeGuessURL, completionHandler: { (data, response, error) -> Void in
            self.pong()
            println(response)
        })
        guessTask.resume()
    }

    func pong() {
        println("pong")
    }
}
