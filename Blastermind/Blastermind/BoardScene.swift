//
//  BoardScene.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.06.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import SpriteKit

func prettyColor<T>(instance: T) -> UIColor {
    var address = unsafeBitCast(instance, Int.self)
    let red =   CGFloat(address >> 0 & 0xFF) / 255.0
    let green = CGFloat(address >> 8 & 0xFF) / 255.0
    let blue =  CGFloat(address >> 16 & 0xFF) / 255.0

    let derivedColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    return derivedColor
}

let defaultColors = [1: UIColor.redColor(), 2: UIColor.orangeColor(),
                     3: UIColor.blueColor(), 4: UIColor.whiteColor(),
                     5: UIColor.greenColor(), 6: UIColor.cyanColor()]


let pegPrefix = "peg"
let submitButtonName = "submitButton"
let quitButtonName = "quitButton"

// layout magic numbers
let leftButtonMargin: CGFloat = 50.0
let topMargin: CGFloat = 30.0

class BoardScene: SKScene {
    var match: Match! // Christian said so (kidding)

    var boardLayout: BoardLayout? // REALLY NOT SWIFTY
    var pegTypes: [PegType] = [] // not Swifty but SHIPIT

    var currentGuessRow = 1
    var nextIndexInGuess = 1
    var currentGuess: [GuessType] = [GuessType.alpha, GuessType.alpha, GuessType.alpha, GuessType.alpha]
    var currentGuessCount = 0

    var currentRoundStatus = RoundStatus.Waiting

    var submitGuessButton: ButtonNode = {
        let button = ButtonNode(color: UIColor.whiteColor(), size: CGSize(width: 60.0,height: 60.0))
        button.text = "Submit"
        button.position = CGPoint(x: leftButtonMargin, y: 100.0)
        button.name = submitButtonName
        return button
    }()

    var quitToHomeButton: ButtonNode = {
        let button = ButtonNode(color: UIColor.blackColor(), size: CGSize(width: 60.0, height: 40.0))
        button.text = "Quit"
        button.position = CGPoint(x: leftButtonMargin, y: 400.0) // TODO: factor this better
        button.name = quitButtonName
        return button
    }()

    override func didMoveToView(view: SKView) {
        self.scaleMode = SKSceneScaleMode.ResizeFill

        println("board scene")
        for node in self.children {
            if let thisNode = node as? SKSpriteNode,
                let nodeName = thisNode.name where startsWith(nodeName, pegPrefix) {
                thisNode.userInteractionEnabled = true
            }
        }

        if boardLayout == nil { return }
        let actualLayout = boardLayout!

        pegTypes = pegTypesForLayout(actualLayout)

        let pegNodes = pegTypes.map {
            (pegType: PegType) -> PegNode in
            var aNewNode = PegNode(color: pegType.guessType.color(), size: pegType.pegSize)
            aNewNode.pegGuessType = pegType.guessType
//            aNewNode.color = prettyColor(aNewNode)
            aNewNode.pegColor = pegType.guessType.color() // just to be safe
//            aNewNode.pegColor = aNewNode.color // shouldn't need to set both colors
            aNewNode.userInteractionEnabled = true
            aNewNode.name = pegType.pegName
            let newXPosition = self.positionForIndex(pegType.pegIndex, segmentWidth: actualLayout.segmentWidth)
            let newYPosition = self.yPositionForBinSegmentsWithWidth(actualLayout.segmentWidth)
            aNewNode.position = CGPoint(x: newXPosition, y: newYPosition)

            self.addChild(aNewNode)
            return aNewNode
        }

        self.submitGuessButton.buttonCallback = sendGuess
        self.addChild(submitGuessButton)

        self.quitToHomeButton.buttonCallback = quitToMainScreen
        self.quitToHomeButton.position = CGPoint(x: leftButtonMargin, y: topOfBoard(self.frame))
        self.addChild(quitToHomeButton)

        // get match name on screen
        let myLabel = SKLabelNode(fontNamed:"Avenir-Next")
        myLabel.text = match.name;
        myLabel.fontSize = 20;
        myLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame) - 20);

        self.addChild(myLabel)
    }

    // MARK: Interact with Board for guesses

    // convenience version
    func fillInNextGuessPeg(pegNode: PegNode) {
        self.fillInGuessPeg(self.currentGuessRow, codeIndex: self.nextIndexInGuess, pegNode: pegNode)
    }

    func fillInGuessPeg(row: Int, codeIndex: Int, pegNode: PegNode) {
        if currentGuessRow > 10 {return}

        ++currentGuessCount

        currentGuess[codeIndex - 1] = pegNode.pegGuessType
        // get position for guess
        let position = positionForCodePeg(row, selectedIndex: codeIndex, layout: self.boardLayout!, binHeight: self.binHeightForSquareSegmentsWithWidth(self.boardLayout!.segmentWidth), inBounds: self.view!.bounds)

        // TODO: make sure we have a spot to put this guess,
        //  or that we remove the old pegNode before adding another

        // turn on effect field and suck in the color tile
        self.addChild(pegNode)

        pegNode.position = position
        // make sure to advance to next unfilled index
        if (nextIndexInGuess < self.boardLayout!.codeWidth) {
            ++self.nextIndexInGuess
            // TODO: go back to earlier indexes
            // TODO: skip already filled-in indexes
        } else if self.nextIndexInGuess > self.boardLayout?.maxGuesses {
            pegNode.removeFromParent()
        }
    }


    // both guessRow and selectedIndex should start at 1
    func positionForCodePeg(guessRow: Int, selectedIndex: Int, layout: BoardLayout, binHeight: CGFloat, inBounds: CGRect) -> CGPoint {
        let numRows = layout.maxGuesses

        let top = topOfBoard(inBounds)
        let bottom = binHeight
        let leadingX = inBounds.size.width / 3 // 1/n width of board for key pegs,the rest for guess pegs
        let trailingX = inBounds.size.width
        let guessRowsHeight = top - bottom
        let guessRowsWidth = trailingX - leadingX
        let guessRowsRect = CGRect(x: leadingX, y: top, width: guessRowsWidth, height: guessRowsHeight)

        let rowHeight = guessRowsHeight/CGFloat(numRows)
        let codePegY = top - (rowHeight * CGFloat(guessRow)) + rowHeight/2.0

        // need space on the far edge
        let codePegWidth = guessRowsWidth / CGFloat(layout.codeWidth)
        let codePegX = leadingX + (codePegWidth * CGFloat(selectedIndex - 1))

        return CGPoint(x: codePegX, y: codePegY)
    }

    func topOfBoard(boardRect: CGRect) -> CGFloat {
        return CGRectGetMaxY(boardRect) - topMargin
    }

    func positionForIndex(index: Int, segmentWidth: CGFloat) -> CGFloat {
        var spacing = segmentWidth / 3.0
        var indexFloat = CGFloat(index)
        return (spacing * indexFloat) + (segmentWidth * indexFloat - 1)
    }

    func yPositionForBinSegmentsWithWidth(width: CGFloat) -> CGFloat {
        return (width * 1/3) + (width * 1/2) // 1/3 of segment height for spacing on either side
    }

    func binHeightForSquareSegmentsWithWidth(width: CGFloat) -> CGFloat {
        return width * 5/3 // 1/3 of segment height for spacing on either side
    }

    func pegTypesForLayout(layout: BoardLayout) -> [PegType] {
        var pegTypes: [PegType] = []
//        let segmentWidth = boardLayout.boardSize.width / boardLayout.
        let desiredHeight = layout.segmentWidth
        for index in 1...layout.pegTypeCount {
            // precondition :index <= 6, GuessType count
            let size = CGSize(width: layout.segmentWidth, height: desiredHeight)
            let peg = PegType(pegName: "pegType\(index)", pegSize:size, pegIndex: index, guessType: GuessType(oneIndex: index)!)
            pegTypes.append(peg)
        }
        return pegTypes
    }

    // MARK: Handle touches

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            if touchedNode.name == submitButtonName {


                sendGuess()
                println("submit")
            }
        }
    }

    // MARK: Guess Logic

    func sendGuess() {

        println("send in the guess!")
        submitGuess(Guess(codeGuess: currentGuess), completion: { (feedback) in
            println("Now Show this feedback, count: <\(feedback.key.count)>")
            let correctedFeedback = Feedback(key: feedback.key, row: self.currentGuessRow)
            self.addFeedbackNodesForFeedback(correctedFeedback)
        })
    }
//    FEEEEEEEEDBACK
    func addFeedbackNodesForFeedback(feed: Feedback) {
        let nodes = KeyNode.nodesForKeys(feed.key)

        for (index, node) in enumerate(nodes) {
            let x = CGFloat(index) * 9.0 + 8
            let y = self.frame.maxY - (CGFloat(currentGuessRow) * 40.0)
            node.position = CGPoint(x: x, y: y)
            self.addChild(node)
        }
    }

    func submitGuess(guess: Guess, completion: Feedback -> ()) {
        // This check doesn't work, b/c I prefill the guess
        if guess.codeGuess.count < 4 { return }

        if currentGuessCount < 4 { return } else { currentGuessCount = 0 }

        appGameEngine().easyGuess(guess, feedCallBack: completion)
        ++self.currentGuessRow
        self.nextIndexInGuess = 1
        self.currentGuess = [GuessType.alpha, GuessType.alpha, GuessType.alpha, GuessType.alpha] // I don't even care anymore
        if outOfGuesses(self.currentGuessRow, maxRows: self.boardLayout!.maxGuesses) {
            self.currentRoundStatus = .Lost
        }

    }

    func outOfGuesses(guessedRowCount: Int, maxRows: Int) -> Bool {
        return guessedRowCount < maxRows
    }

    // MARK: App transitions

    func quitToMainScreen() {
        println("transition goes here")
        // also make sure any server sessions are ended or quit, for now
    }

    // MARK: Debug methods
//    func fakeGuess() -> Guess {
//        return Guess(codeGuess: [GuessType.alpha,GuessType.alpha,GuessType.beta,GuessType.zeta])
//    }
//    func fakeFeedback() -> Feedback {
//        return Feedback(key: [.CorrectType, .CorrectType], row: 1)
//    }


    // dirty dirty gross
    func appGameEngine() -> GameEngine! {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        return app.engine
    }
}

class PegNode : SKSpriteNode {
    var pegType = PegTypeOption.Color(UIColor.redColor())
    @IBInspectable var pegColor = UIColor.redColor()
    @IBInspectable var pegValue = 0
    var pegGuessType = GuessType.alpha

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches as! Set<UITouch> {
            var location = touch.locationInView(self.scene!.view)
            if let touchedNode = self.nodeAtPoint(location) as? PegNode {
                let newPeg = touchedNode.copy() as! PegNode
                newPeg.pegGuessType = touchedNode.pegGuessType // *sigh*
                newPeg.name = "userPeg"
                let board = touchedNode.scene! as! BoardScene
                board.fillInNextGuessPeg(newPeg)
            }

        }

    }
}

class KeyNode: SKSpriteNode {
    var keyType: KeyType = KeyType.CorrectType

    func keyColor() -> UIColor {
        return (keyType == .CorrectType) ? UIColor.darkGrayColor() : UIColor.redColor()
    }

    class func nodesForKeys(types: [KeyType]) -> [KeyNode] {
        return types.map {
            (type: KeyType) -> KeyNode in
            let node = KeyNode(color: UIColor.whiteColor(), size: CGSize(width: 6.0, height: 6.0))
            node.keyType = type
            node.color = node.keyColor()
            return node
        }
    }
}

class ButtonNode: SKSpriteNode {
    var buttonCallback: (()->())?
    var text: String?

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches as! Set<UITouch> {
            var location = touch.locationInView(self.scene!.view)
            if let touchedNode = self.nodeAtPoint(location) as? ButtonNode,
            let actualButtonCallback = buttonCallback {
                actualButtonCallback()
            }
        }
    }
}

func partitionWidth(width: Int, forNumberOfSegments: Int) {

}

/*
struct TypeNode {
    var

    class func layoutTypes(types: [PegTypeOption], inArea:CGRect) -> {
        let count = types.count

    }

}
*/
