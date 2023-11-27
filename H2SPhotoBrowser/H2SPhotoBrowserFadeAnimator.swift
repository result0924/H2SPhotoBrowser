//
//  H2SPhotoBrowserFadeAnimator.swift
//  H2SPhotoBrowser
//
//  Created by jlai on 2023/11/24.
//

import UIKit

open class H2SPhotoBrowserFadeAnimator: NSObject, H2SPhotoBrowserAnimatedTransitioning {
    
    open var showDuration: TimeInterval = 0.25
    
    open var dismissDuration: TimeInterval = 0.25
    
    public var isNavigationAnimation: Bool = false
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return isForShow ? showDuration : dismissDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let browser = photoBrowser else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        if isNavigationAnimation, isForShow,
            let fromView = transitionContext.view(forKey: .from),
            let fromViewSnapshot = snapshot(with: fromView),
            let toView = transitionContext.view(forKey: .to)  {
            toView.insertSubview(fromViewSnapshot, at: 0)
        }
        if isForShow {
            browser.maskView.alpha = 0
            browser.browserView.alpha = 0
            if let toView = transitionContext.view(forKey: .to) {
                transitionContext.containerView.addSubview(toView)
            }
        } else {
            if isNavigationAnimation,
                let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) {
                transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
            }
        }
        browser.browserView.isHidden = true
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            browser.browserView.isHidden = false
            browser.maskView.alpha = self.isForShow ? 1.0 : 0
            browser.browserView.alpha = self.isForShow ? 1.0 : 0
        }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
