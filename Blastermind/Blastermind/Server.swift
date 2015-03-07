//
//  Server.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.05.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

class Server: NSObject, PTPusherDelegate {
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
    let URL = NSURL(string:"http://private-73307-blastermind.apiary-mock.com/matches/801/guesses")!

    lazy var session: NSURLSession = {
        return NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    }()

    func guess([Int], result:([Int]) -> ()) {
        let guessTask = session.dataTaskWithURL(URL, completionHandler: { (data, response, error) -> Void in
            self.pong()
            println(response)
        })
        guessTask.resume()
    }

    func pong() {
        println("pong")
    }
}
