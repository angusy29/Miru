//
//  Util.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func setBottomBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect.init(x: 0.0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.white.cgColor
        self.borderStyle = .none
        self.layer.addSublayer(bottomBorder)
    }
}
