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
        /* Setup your scene here */
        var centerX = CGRectGetMidX(self.frame)

        let myLabel = SKLabelNode(fontNamed:"Avenir-Next")
        myLabel.text = "Blast Your Mind";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x: centerX, y:CGRectGetMaxY(self.frame) - 80);
        
        self.addChild(myLabel)

        let startThingy = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(60.0, 30.0))
        startThingy.position = CGPoint(x: centerX, y: CGRectGetMidY(self.frame))
        startThingy.name = startButtonName

        self.addChild(startThingy)
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            if touchedNode.name == startButtonName {
                // change scene
                let boardScene = BoardScene.unarchiveFromFile("BoardScene") as! BoardScene
                let transition = SKTransition.doorsOpenHorizontalWithDuration(1.0)

                self.view?.presentScene(boardScene, transition: transition)
            }

        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
