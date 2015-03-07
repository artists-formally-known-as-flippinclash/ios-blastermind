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

class BoardScene: SKScene {
    var boardLayout: BoardLayout? // REALLY NOT SWIFTY
    var pegTypes: [PegType] = [] // not Swifty but SHIPIT

    var currentGuessRow = 1
    var nextIndexInGuess = 1

    var currentRoundStatus = RoundStatus.Waiting

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
            var aNewNode = PegNode(color: UIColor.orangeColor(), size: pegType.pegSize)
            aNewNode.color = prettyColor(aNewNode)
            aNewNode.pegColor = aNewNode.color // shouldn't need to set both colors
            aNewNode.userInteractionEnabled = true
            aNewNode.name = pegType.pegName
            let newXPosition = self.positionForIndex(pegType.pegIndex, segmentWidth: actualLayout.segmentWidth)
            let newYPosition = self.yPositionForBinSegmentsWithWidth(actualLayout.segmentWidth)
            aNewNode.position = CGPoint(x: newXPosition, y: newYPosition)

            self.addChild(aNewNode)
            return aNewNode
        }
    }

    // MARK: Interact with Board for guesses

    // convenience version
    func fillInNextGuessPeg(pegNode: PegNode) {
        self.fillInGuessPeg(self.currentGuessRow, codeIndex: self.nextIndexInGuess, pegNode: pegNode)
    }

    func fillInGuessPeg(row: Int, codeIndex: Int, pegNode: PegNode) {
        // get position for guess
        let position = positionForCodePeg(row, selectedIndex: codeIndex, layout: self.boardLayout!, binHeight: self.binHeightForSquareSegmentsWithWidth(self.boardLayout!.segmentWidth), inBounds: self.view!.bounds)

        // turn on effect field and suck in the color tile
        self.addChild(pegNode)

        pegNode.position = position
        // make sure to advance to next unfilled index
        if (nextIndexInGuess < self.boardLayout!.codeWidth) {
            ++self.nextIndexInGuess
            // TODO: go back to earlier indexes
            // TODO: skip already filled-in indexes
        }
    }


    // both guessRow and selectedIndex should start at 1
    func positionForCodePeg(guessRow: Int, selectedIndex: Int, layout: BoardLayout, binHeight: CGFloat, inBounds: CGRect) -> CGPoint {
        let numRows = layout.maxGuesses

        let top = CGRectGetMaxY(inBounds)
        let bottom = binHeight
        let leadingX = inBounds.size.width / 4 // 1/4 width of board for key pegs, 3/4 for guess pegs
        let trailingX = inBounds.size.width
        let guessRowsHeight = top - bottom
        let guessRowsWidth = trailingX - leadingX
        let guessRowsRect = CGRect(x: leadingX, y: top, width: guessRowsWidth, height: guessRowsHeight)

        let rowHeight = guessRowsHeight/CGFloat(numRows)
        let codePegY = top - (rowHeight * CGFloat(guessRow))

        // need space on the far edge
        let codePegWidth = guessRowsWidth / CGFloat(layout.codeWidth + 1)
        let codePegX = leadingX + (codePegWidth * CGFloat(selectedIndex - 1))

        return CGPoint(x: codePegX, y: codePegY)
    }

    func positionForIndex(index: Int, segmentWidth: CGFloat) -> CGFloat {
        var spacing = segmentWidth / 3.0
        var indexFloat = CGFloat(index)
        return (spacing * indexFloat) + (segmentWidth * indexFloat - 1)
    }

    func yPositionForBinSegmentsWithWidth(width: CGFloat) -> CGFloat {
        return width * 1/3 // 1/3 of segment height for spacing on either side
    }

    func binHeightForSquareSegmentsWithWidth(width: CGFloat) -> CGFloat {
        return width * 5/3 // 1/3 of segment height for spacing on either side
    }

    func pegTypesForLayout(layout: BoardLayout) -> [PegType] {
        var pegTypes: [PegType] = []
//        let segmentWidth = boardLayout.boardSize.width / boardLayout.
        let desiredHeight = layout.segmentWidth
        for index in 1...layout.pegTypeCount {
            let size = CGSize(width: layout.segmentWidth, height: desiredHeight)
            let peg = PegType(pegName: "pegType\(index)", pegSize:size, pegIndex: index)
            pegTypes.append(peg)
        }
        return pegTypes
    }

    // MARK: Guess Logic

    func checkGuess(guess: Guess, completion: Feedback -> ()) {
        completion(fakeFeedback())
        ++self.currentGuessRow
        if outOfGuesses(self.currentGuessRow, maxRows: self.boardLayout!.maxGuesses) {
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

class PegNode : SKSpriteNode {
    var pegType = PegTypeOption.Color(UIColor.redColor())
    @IBInspectable var pegColor = UIColor.redColor()
    @IBInspectable var pegValue = 0

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        for touch in touches as! Set<UITouch> {
            var location = touch.locationInView(self.scene!.view)
            if let touchedNode = self.nodeAtPoint(location) as? PegNode {
                let newPeg = touchedNode.copy() as! PegNode
                newPeg.name = "userPeg"
                let board = touchedNode.scene! as! BoardScene
                board.fillInNextGuessPeg(newPeg)
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
