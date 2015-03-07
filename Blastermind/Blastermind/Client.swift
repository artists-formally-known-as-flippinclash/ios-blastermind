//
//  Server.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.05.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

class Client: NSObject, PTPusherDelegate {
    lazy var client: PTPusher = {
        return PTPusher.pusherWithKey("a8dc613841aa8963a8a4", delegate: self) as! PTPusher
    }()

    var gameChannel: PTPusherChannel?

    func startClient() {
        self.client.connect()
        let gameChannel = self.client.subscribeToChannelNamed("game-us")
        gameChannel.bindToEventNamed("match-started", handleWithBlock: {
            eventData in
            self.ping(eventData)
        })
        self.gameChannel = gameChannel
    }

    func ping(event: PTPusherEvent) {
        println("ping")
    }
}

class ServerConnection {
    let baseString = "http://api.blasterminds.com"
    let fakeGuessURL = NSURL(string:"http://private-73307-blastermind.apiary-mock.com/matches/801/guesses")!

    lazy var session: NSURLSession = {
        return NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    }()

    func requestNewMatch(player: SuggestedPlayer, callback: ()->() ) {
        let req = createMatchRequest(player)
        let matchTask = session.dataTaskWithRequest(req, completionHandler: { (data, response, error) -> Void in
            println("response: <\(response)")
            callback()
        })

        matchTask.resume()
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
        let fullString = baseString.stringByAppendingPathComponent(endpoint)
        let fullURL = NSURL(string: fullString)
        return fullURL
    }

    // MARK: convenience urls
    let createMatchString = "matches"
    func requestMatchURL() -> NSURL? {
        return fullURLForEndpoint(createMatchString)
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
