//
//  CategoriesOfEndofunctors.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.07.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit


// MARK: Class Helpers and Current Theme

struct CurrentScheme {
    static let schemeName: ColorSchemeNames = ColorSchemeNames.Primary
}


enum ColorSchemeNames {
    case Primary, Bright, Subdued
}

extension UIColor {
    // takes Ints up to 255 and divides them for you
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
}


// MARK: Colors

// codes, named theme areas
// add named colors here like primaryButton, text, winBackground
extension UIColor {
    class func alphaColor() -> UIColor {
        var color: UIColor
        switch CurrentScheme.schemeName {
        case .Primary:
            color = UIColor.redColor()
        case .Bright:
            color = UIColor.brightRedColor()
        case .Subdued:
            color = UIColor.redColor()
        }
        return color
    }


    class func betaColor() -> UIColor {
        var color: UIColor
        switch CurrentScheme.schemeName {
        case .Primary:
            color = UIColor.orangeColor()
        case .Bright:
            color = UIColor.brightOrangeColor()
        case .Subdued:
            color = UIColor.orangeColor()
        }
        return color

    }

    class func gammaColor() -> UIColor {
        var color: UIColor
        switch CurrentScheme.schemeName {
        case .Primary:
            color = UIColor.yellowColor()
        case .Bright:
            color = UIColor.brightYellowColor()
        case .Subdued:
            color = UIColor.yellowColor()
        }
        return color

    }

    class func deltaColor() -> UIColor {
        var color: UIColor
        switch CurrentScheme.schemeName {
        case .Primary:
            color = UIColor.greenColor()
        case .Bright:
            color = UIColor.brightGreenColor()
        case .Subdued:
            color = UIColor.greenColor()
        }
        return color

    }

    class func epsilonColor() -> UIColor {
        var color: UIColor
        switch CurrentScheme.schemeName {
        case .Primary:
            color = UIColor.blueColor()
        case .Bright:
            color = UIColor.brightBlueColor()
        case .Subdued:
            color = UIColor.blueColor()
        }
        return color

    }

    class func zetaColor() -> UIColor {
        var color: UIColor
        switch CurrentScheme.schemeName {
        case .Primary:
            color = UIColor.purpleColor()
        case .Bright:
            color = UIColor.brightPurpleColor()
        case .Subdued:
            color = UIColor.purpleColor()
        }
        return color
    }
}



// Bright
extension UIColor {
    class func brightRedColor() -> UIColor {
        return UIColor.redColor()
    }
    class func brightBlueColor() -> UIColor {
        return UIColor.blueColor()
    }
    class func brightGreenColor() -> UIColor {
        return UIColor.greenColor()
    }
    class func brightYellowColor() -> UIColor {
        return UIColor.yellowColor()
    }
    class func brightOrangeColor() -> UIColor {
        return UIColor.orangeColor()
    }
    class func brightPurpleColor() -> UIColor {
        return UIColor.purpleColor()
    }
}

// Add other specific theme colors here

