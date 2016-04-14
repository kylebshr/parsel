//
//  UIImage+Extensions.swift
//  Snapstahp
//
//  Created by Kyle Bashour on 4/13/16.
//  Copyright © 2016 Kyle Bashour. All rights reserved.
//

import UIKit

extension UIImage {

    func encode() -> String? {

        guard let imageData = UIImagePNGRepresentation(self) else {
            return nil
        }

        return imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }

    convenience init?(base64String: String) {

        guard let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters) else {
            return nil
        }

        self.init(data: decodedData)
    }
}
