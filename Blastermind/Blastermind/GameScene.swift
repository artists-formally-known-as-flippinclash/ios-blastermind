//
//  GameScene.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.05.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import SpriteKit

let startButtonText = "Start"
let startButtonName = "startButton"

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.scaleMode = SKSceneScaleMode.ResizeFill // doesn't appear to be working. Wat.
        self.size = self.view!.frame.size
        var centerX = CGRectGetMidX(self.frame)

        // Title
        let myLabel = SKLabelNode(fontNamed:"Avenir-Next")
        myLabel.text = "Blast Your Mind";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x: centerX, y:CGRectGetMaxY(self.frame) - 80);
        
        self.addChild(myLabel)

        // Start Button
        let startThingy = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(150.0, 50.0))
        startThingy.position = CGPoint(x: centerX, y: CGRectGetMidY(self.frame))
        startThingy.name = startButtonName

        let startLabel = SKLabelNode(fontNamed: "Avenir-Next-Bold")
        startLabel.text = startButtonText
        startLabel.fontSize = 24
        startLabel.fontColor = UIColor.blackColor()
        startLabel.position = CGPoint(x: 0.0, y: -10.0)
        startLabel.name = "startLabel"
        startLabel.userInteractionEnabled = true // FIXME: label isn't handling touches right
        startThingy.addChild(startLabel)

        self.addChild(startThingy)

        // DEBUG:
//        switchToBoard()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            switchToBoard()
        }
    }

    func switchToBoard() {
        let boardScene = BoardScene.unarchiveFromFile("BoardScene") as! BoardScene
        boardScene.scaleMode = SKSceneScaleMode.ResizeFill
        boardScene.size = self.size
        boardScene.boardLayout = BoardLayout(boardSize: self.size) // SHIPIT dirty hack
        let transition = SKTransition.doorsOpenVerticalWithDuration(1.0)

        self.view?.presentScene(boardScene, transition: transition)

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
