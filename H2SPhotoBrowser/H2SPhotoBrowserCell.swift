//
//  H2SPhotoBrowserCell.swift
//  H2SPhotoBrowser
//
//  Created by jlai on 2023/11/24.
//

import UIKit

public protocol H2SPhotoBrowserCell: UIView {
    static func generate(with browser: H2SPhotoBrowser) -> Self
}
