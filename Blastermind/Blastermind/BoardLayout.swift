//
//  BoardRules.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.06.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreGraphics

let defaultBoard = 1

struct BoardLayout {
    let codeWidth = 4
    let maxGuesses = 10

    let pegTypeCount = 6
    let boardSize: CGSize

    var segmentWidth: CGFloat {
        // make spaces between each peg, and on both sides.
        // this layout info should probably live elsewhere
        let floatedCount = CGFloat(pegTypeCount)
        let segmentsNeeded = floatedCount + (floatedCount + 1)*3
        let spacing = boardSize.width / segmentsNeeded
        return spacing * 3
//        return CGSize(width: segmentWidth, height: boardSize.height)
    }

    init (boardSize: CGSize) {
        self.boardSize = boardSize
    }
    /*
    func buildTypePegs<T: PegType>(type: T) -> [T] {
        let typePegs = map(1...6) {
            (index: Int) -> T in
            let result = T()
        }
    }
    */
}

struct PegType {
    var pegName: String
    var pegSize: CGSize
    var pegIndex: Int
    // node?
}