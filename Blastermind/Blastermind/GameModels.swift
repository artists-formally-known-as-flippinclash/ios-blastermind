//
//  GameModels.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.06.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

struct Guess {
    var codeGuess: [Int]
}

struct Feedback {
    let key: [KeyType] // should this just be count of each type instead?
}

enum KeyType {
    case CorrectType, CorrectTypeAndPosition
}

enum PegTypeOption {
    case Color(UIColor), Shape(SKShapeNode), Number(Int)
}

enum RoundStatus {
    case Waiting, InProgress, Won, Lost, Broken
}

// Enum is probably wrong type here, since there might be more or less than 6
//enum PegType: PegTypeOption { // T == PegTypeOption
//    case A(PegTypeOption), B(PegTypeOption), C(PegTypeOption), D(PegTypeOption), E(PegTypeOption), F(PegTypeOption)
//}
