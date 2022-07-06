//
//  MarrytingButton.swift
//  CustomButton
//
//  Created by Woody on 2022/07/06.
//

import UIKit

/// 코드
final class MarrytingButton: UIButton {
    private let selectedTextColor: UIColor = UIColor.white
    private let unselectedTextColor: UIColor = .init(rgb: 0x242424)
    private let disabledTextColor: UIColor = .init(rgb: 0xBABABA)
    
    private let disabledBackgroundColor: UIColor = .init(rgb: 0x949494)
    private let defaultBackgroundColor: UIColor = .init(rgb: 0xC6DC84)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    func layout() {
        
    }
    
    func attribute() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
