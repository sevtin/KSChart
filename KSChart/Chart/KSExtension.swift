//
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

extension Array where Element: Equatable {
    
    subscript (safe index: Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
    
    mutating func ks_removeObject(_ object: Element) {
        if let index = self.firstIndex(of: object) {
            self.remove(at: index)
        }
    }
    
    mutating func ks_removeObjectsInArray(_ array: [Element]) {
        for object in array {
            self.ks_removeObject(object)
        }
    }
}
