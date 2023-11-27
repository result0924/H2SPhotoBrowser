//
//  H2SPhotoBrowserImageView.swift
//  H2SPhotoBrowser
//
//  Created by jlai on 2023/11/24.
//

import UIKit

public class H2SPhotoBrowserImageView: UIImageView {
    
    public var imageDidChangedHandler: (() -> ())?
    
    public override var image: UIImage? {
        didSet {
            imageDidChangedHandler?()
        }
    }
}
