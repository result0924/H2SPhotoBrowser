//
//  H2SPhotoBrowser.swift
//  H2SPhotoBrowser
//
//  Created by jlai on 2023/11/24.
//

import UIKit

open class H2SPhotoBrowser: UIViewController {
    public enum ScrollDirection {
        case horizontal
        case vertical
    }
    
    public typealias ReloadCellContext = (cell: H2SPhotoBrowserCell, index: Int, currentIndex: Int)
    public typealias PresentEmbedClosure = (H2SPhotoBrowser) -> UINavigationController
    
    open weak var previousNavigationControllerDelegate: UINavigationControllerDelegate?
    
    open class var topViewController: UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        return topViewController(of: keyWindow?.rootViewController)
    }
    
    open class func topViewController(of viewController: UIViewController?) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return topViewController(of: presentedViewController)
        }
        
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return topViewController(of: selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return topViewController(of: visibleViewController)
        }
        
        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
            pageViewController.viewControllers?.count == 1 {
            return topViewController(of: pageViewController.viewControllers?.first)
        }
        
        // child view controller
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return topViewController(of: childViewController)
            }
        }
        
        return viewController
    }
    
    open var pageIndicator: H2SPhotoBrowserPageIndicator?
    
    open var isPreviousNavigationBarHidden: Bool?
    
    open var reloadCellAtIndex: (ReloadCellContext) -> Void {
        set { browserView.reloadCellAtIndex = newValue }
        get { return browserView.reloadCellAtIndex }
    }
    
    open var scrollDirection: H2SPhotoBrowser.ScrollDirection {
        set { browserView.scrollDirection = newValue }
        get { return browserView.scrollDirection }
    }
    
    open var itemSpacing: CGFloat {
        set { browserView.itemSpacing = newValue }
        get { return browserView.itemSpacing }
    }
    
    open var pageIndex: Int {
        set { browserView.pageIndex = newValue }
        get { return browserView.pageIndex }
    }
    
    open var numberOfItems: () -> Int {
        set { browserView.numberOfItems = newValue }
        get { return browserView.numberOfItems }
    }
    
    open var cellClassAtIndex: (_ index: Int) -> H2SPhotoBrowserCell.Type {
        set { browserView.cellClassAtIndex = newValue }
        get { return browserView.cellClassAtIndex }
    }
    
    open var cellWillAppear: (H2SPhotoBrowserCell, Int) -> Void {
        set { browserView.cellWillAppear = newValue }
        get { return browserView.cellWillAppear }
    }
    
    open var cellWillDisappear: (H2SPhotoBrowserCell, Int) -> Void {
        set { browserView.cellWillDisappear = newValue }
        get { return browserView.cellWillDisappear }
    }
    
    open var cellDidAppear: (H2SPhotoBrowserCell, Int) -> Void {
        set { browserView.cellDidAppear = newValue }
        get { return browserView.cellDidAppear }
    }
    
    open lazy var browserView = H2SPhotoBrowserView()
    
    open lazy var didChangedPageIndex: (_ index: Int) -> Void = { _ in }
    
    open lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    open lazy var transitionAnimator: H2SPhotoBrowserAnimatedTransitioning = H2SPhotoBrowserFadeAnimator()
    
    open override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    open func setStatusBar(hidden: Bool) {
        if hidden {
            isStatusBarHidden = true
        } else {
            isStatusBarHidden = isPreviousStatusBarHidden
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    
    open func dismiss() {
        setStatusBar(hidden: false)
        pageIndicator?.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }
    
    private lazy var isStatusBarHidden = self.isPreviousStatusBarHidden
    
    private lazy var isPreviousStatusBarHidden: Bool = {
        var previousVC: UIViewController?
        if let vc = self.presentingViewController {
            previousVC = vc
        }
        return previousVC?.prefersStatusBarHidden ?? false
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func show(fromVC: UIViewController? = nil, embed: PresentEmbedClosure? = nil) {
        let toVC = embed?(self) ?? self
        toVC.modalPresentationStyle = .custom
        toVC.modalPresentationCapturesStatusBarAppearance = true
        toVC.transitioningDelegate = self
        let from = fromVC ?? H2SPhotoBrowser.topViewController
        from?.present(toVC, animated: true, completion: nil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        hideNavigationBar(true)
        
        browserView.photoBrowser = self
        transitionAnimator.photoBrowser = self
        
        view.backgroundColor = .clear
        view.addSubview(maskView)
        view.addSubview(browserView)
        
        browserView.didChangedPageIndex = { [weak self] index in
            guard let `self` = self else { return }
            self.pageIndicator?.didChanged(pageIndex: index)
            self.didChangedPageIndex(index)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        maskView.frame = view.bounds
        browserView.frame = view.bounds
        pageIndicator?.reloadData(numberOfItems: numberOfItems(), pageIndex: pageIndex)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(true)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = previousNavigationControllerDelegate
        if let indicator = pageIndicator {
            view.addSubview(indicator)
            indicator.setup(with: self)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavigationBar(false)
    }
    
    private func hideNavigationBar(_ hide: Bool) {
        if hide {
            if isPreviousNavigationBarHidden == nil {
                isPreviousNavigationBarHidden = navigationController?.isNavigationBarHidden
            }
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            if let barHidden = isPreviousNavigationBarHidden {
                navigationController?.setNavigationBarHidden(barHidden, animated: false)
            }
        }
    }
    
}

extension H2SPhotoBrowser: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.isForShow = (operation == .push)
        transitionAnimator.photoBrowser = self
        transitionAnimator.isNavigationAnimation = true
        return transitionAnimator
    }
}

extension H2SPhotoBrowser: UIViewControllerTransitioningDelegate {
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        browserView.isRotating = true
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.isForShow = true
        transitionAnimator.photoBrowser = self
        return transitionAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.isForShow = false
        transitionAnimator.photoBrowser = self
        return transitionAnimator
    }
}
