//
//  BoardScene.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.06.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import SpriteKit

let pegPrefix = "peg"

class BoardScene: SKScene {
    var guessWidth = 4
    var maxGuesses = 10

    var currentGuessRow = 0
    var nextIndexInGuess = 0

    var currentRoundStatus = RoundStatus.Waiting

    override func didMoveToView(view: SKView) {
        println("board scene")
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches as! Set<UITouch> {
            // extend SKScene with this instead? JQuery style lookup?
            var location = touch.locationInView(self.view)
            let touchedNode = self.nodeAtPoint(location)
            if let name = touchedNode.name where startsWith(name, pegPrefix) {
                // change this peg to selected state
                let newPeg = touchedNode.copy() as! SKSpriteNode
                newPeg.name = "userPeg"
                newPeg.position = CGPoint(x: touchedNode.position.x - 10.0, y: touchedNode.position.y + 40.0)
                self.addChild(newPeg)
            }
        }
    }

    func checkGuess(guess: Guess, completion: Feedback -> ()) {
        completion(fakeFeedback())
        ++self.currentGuessRow
        if outOfGuesses(self.currentGuessRow, maxRows: self.maxGuesses) {
            self.currentRoundStatus = .Lost
        }

    }

    func outOfGuesses(guessedRowCount: Int, maxRows: Int) -> Bool {
        return guessedRowCount < maxRows
    }

    // MARK: Debug methods
    func fakeGuess() -> Guess {
        return Guess(codeGuess: [0, 0, 1, 1])
    }

    func fakeFeedback() -> Feedback {
        return Feedback(key: [.CorrectType, .CorrectType])
    }
}


