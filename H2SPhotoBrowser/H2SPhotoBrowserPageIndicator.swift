//
//  H2SPhotoBrowserPageIndicator.swift
//  H2SPhotoBrowser
//
//  Created by jlai on 2023/11/24.
//

import UIKit

public protocol H2SPhotoBrowserPageIndicator: UIView {
    
    func setup(with browser: H2SPhotoBrowser)
    
    func reloadData(pageIndex: Int)
    
    func didChanged(pageIndex: Int)
}
