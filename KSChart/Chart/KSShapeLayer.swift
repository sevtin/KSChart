//
//  ZeroShare
//
//  Created by saeipi on 2019/6/6.
//  Copyright © 2019 saeipi. All rights reserved.
//

import UIKit

class KSShapeLayer: CAShapeLayer {
    
    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

class KSTextLayer: CATextLayer {
    
    // 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
    override func action(forKey event: String) -> CAAction? {
        return nil
    }
}

class KSLayer: CALayer {
    /*
    deinit {
        print("------ KSLayer deinit ------")
    }
     */
}
