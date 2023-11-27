//
//  H2SPhotoBrowserAnimatedTransitioning.swift
//  H2SPhotoBrowser
//
//  Created by jlai on 2023/11/24.
//

import UIKit

public protocol H2SPhotoBrowserAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    var isForShow: Bool { get set }
    var photoBrowser: H2SPhotoBrowser? { get set }
    var isNavigationAnimation: Bool { get set }
}

private var isForShowH2SphotoBrowserKey = "isForShowH2SphotoBrowserKey"
private var h2sphotoBrowserKey = "h2sphotoBrowserKey"

extension H2SPhotoBrowserAnimatedTransitioning {
    
    public var isForShow: Bool {
        get {
            if let value = objc_getAssociatedObject(self, isForShowH2SphotoBrowserKey.withCString { $0 }) as? Bool {
                return value
            }
            return true
        }
        set {
            objc_setAssociatedObject(self, isForShowH2SphotoBrowserKey.withCString { $0 }, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    public weak var photoBrowser: H2SPhotoBrowser? {
        get {
            return objc_getAssociatedObject(self, h2sphotoBrowserKey.withCString { $0 }) as? H2SPhotoBrowser
        }
        set {
            objc_setAssociatedObject(self, h2sphotoBrowserKey.withCString { $0 }, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    public var isNavigationAnimation: Bool {
        get { return false }
        set { }
    }
    
    public func fastSnapshot(with view: UIView) -> UIView? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImageView(image: image)
    }
    
    public func snapshot(with view: UIView) -> UIView? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImageView(image: image)
    }
}

