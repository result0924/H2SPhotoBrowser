//
//  H2SPhotoBrowserImageCell.swift
//  H2SPhotoBrowser
//
//  Created by jlai on 2023/11/24.
//

import UIKit

open class H2SPhotoBrowserImageCell: UIView {
    open weak var photoBrowser: H2SPhotoBrowser?
    
    open var index: Int = 0
    
    open var scrollDirection: H2SPhotoBrowser.ScrollDirection = .horizontal {
        didSet {
            if scrollDirection == .horizontal {
                addPanGesture()
            } else if let existed = existedPan {
                scrollView.removeGestureRecognizer(existed)
            }
        }
    }
    
    open var showContentView: UIView {
        return imageView
    }
    
    open var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.maximumZoomScale = 2.0
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    open lazy var imageView: H2SPhotoBrowserImageView = {
        let imgView = H2SPhotoBrowserImageView()
        imgView.clipsToBounds = true
        imgView.imageDidChangedHandler = { [weak self] in
            self?.setNeedsLayout()
        }
        return imgView
    }()
    
    private lazy var longPress: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(_:)))
    }()
    private typealias LongPressAction = (H2SPhotoBrowserImageCell, UILongPressGestureRecognizer) -> Void
    private var longPressedAction: LongPressAction? {
        didSet {
            if oldValue != nil && longPressedAction == nil {
                removeGestureRecognizer(longPress)
            } else if oldValue == nil && longPressedAction != nil {
                addGestureRecognizer(longPress)
            }
        }
    }
    private weak var existedPan: UIPanGestureRecognizer?
    /// 記錄pan手勢開始時imageView的位置
    private var beganFrame = CGRect.zero
    /// 記錄pan手勢開始時，手勢位置
    private var beganTouch = CGPoint.zero
    
    public required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        scrollView.setZoomScale(1.0, animated: false)
        let size = computeImageLayoutSize(for: imageView.image, in: scrollView)
        let origin = computeImageLayoutOrigin(for: size, in: scrollView)
        imageView.frame = CGRect(origin: origin, size: size)
        scrollView.setZoomScale(1.0, animated: false)
    }
    
    private func setup() {
        backgroundColor = .clear
        constructSubviews()
        
        addPanGesture()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(onSingleTap(_:)))
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
    }
    
    private func constructSubviews() {
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.addSubview(imageView)
    }
    
    private func computeImageLayoutSize(for image: UIImage?, in scrollView: UIScrollView) -> CGSize {
        guard let imageSize = image?.size, imageSize.width > 0 && imageSize.height > 0 else {
            return .zero
        }
        var width: CGFloat
        var height: CGFloat
        let containerSize = scrollView.bounds.size
        if scrollDirection == .horizontal {
            // 横竖屏判断
            if containerSize.width < containerSize.height {
                width = containerSize.width
                height = imageSize.height / imageSize.width * width
            } else {
                height = containerSize.height
                width = imageSize.width / imageSize.height * height
                if width > containerSize.width {
                    width = containerSize.width
                    height = imageSize.height / imageSize.width * width
                }
            }
        } else {
            width = containerSize.width
            height = imageSize.height / imageSize.width * width
            if height > containerSize.height {
                height = containerSize.height
                width = imageSize.width / imageSize.height * height
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    private func computeImageLayoutOrigin(for imageSize: CGSize, in scrollView: UIScrollView) -> CGPoint {
        let containerSize = scrollView.bounds.size
        var y = (containerSize.height - imageSize.height) * 0.5
        y = max(0, y)
        var x = (containerSize.width - imageSize.width) * 0.5
        x = max(0, x)
        return CGPoint(x: x, y: y)
    }
    
    private func addPanGesture() {
        guard existedPan == nil else {
            return
        }
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        
        scrollView.addGestureRecognizer(pan)
        existedPan = pan
    }
    
    private func computeImageLayoutCenter(in scrollView: UIScrollView) -> CGPoint {
        var x = scrollView.contentSize.width * 0.5
        var y = scrollView.contentSize.height * 0.5
        let offsetX = (bounds.width - scrollView.contentSize.width) * 0.5
        if offsetX > 0 {
            x += offsetX
        }
        let offsetY = (bounds.height - scrollView.contentSize.height) * 0.5
        if offsetY > 0 {
            y += offsetY
        }
        return CGPoint(x: x, y: y)
    }
    
    /// 恢復ImageView
    private func resetImageViewPosition() {
        // 如果圖片目前顯示的size小於原size，則重設為原size
        let size = computeImageLayoutSize(for: imageView.image, in: scrollView)
        let needResetSize = imageView.bounds.size.width < size.width || imageView.bounds.size.height < size.height
        UIView.animate(withDuration: 0.25) {
            self.imageView.center = self.computeImageLayoutCenter(in: self.scrollView)
            if needResetSize {
                self.imageView.bounds.size = size
            }
        }
    }
    
}

extension H2SPhotoBrowserImageCell: H2SPhotoBrowserCell {
    public static func generate(with browser: H2SPhotoBrowser) -> Self {
        let cell = Self.init(frame: .zero)
        cell.photoBrowser = browser
        cell.scrollDirection = browser.scrollDirection
        return cell
    }
}

extension H2SPhotoBrowserImageCell: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = computeImageLayoutCenter(in: scrollView)
    }
}

extension H2SPhotoBrowserImageCell: UIGestureRecognizerDelegate {
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let velocity = pan.velocity(in: self)

        if velocity.y < 0 {
            return false
        }
        
        if abs(Int(velocity.x)) > Int(velocity.y) {
            return false
        }
        
        if scrollView.contentOffset.y > 0 {
            return false
        }
        
        return true
    }
    
    @objc private func onPan(_ pan: UIPanGestureRecognizer) {
        guard imageView.image != nil else {
            return
        }
        switch pan.state {
        case .began:
            beganFrame = imageView.frame
            beganTouch = pan.location(in: scrollView)
        case .changed:
            let result = panResult(pan)
            imageView.frame = result.frame
            photoBrowser?.maskView.alpha = result.scale * result.scale
            photoBrowser?.setStatusBar(hidden: result.scale > 0.99)
            photoBrowser?.pageIndicator?.isHidden = result.scale < 0.99
        case .ended, .cancelled:
            imageView.frame = panResult(pan).frame
            let isDown = pan.velocity(in: self).y > 0
            if isDown {
                photoBrowser?.dismiss()
            } else {
                photoBrowser?.maskView.alpha = 1.0
                photoBrowser?.setStatusBar(hidden: true)
                photoBrowser?.pageIndicator?.isHidden = false
                resetImageViewPosition()
            }
        default:
            resetImageViewPosition()
        }
    }
    
    @objc private func onSingleTap(_ tap: UITapGestureRecognizer) {
        photoBrowser?.dismiss()
    }
    
    @objc private func onDoubleTap(_ tap: UITapGestureRecognizer) {
        if scrollView.zoomScale < 1.1 {
            let pointInView = tap.location(in: imageView)
            let width = scrollView.bounds.size.width / scrollView.maximumZoomScale
            let height = scrollView.bounds.size.height / scrollView.maximumZoomScale
            let x = pointInView.x - (width / 2.0)
            let y = pointInView.y - (height / 2.0)
            scrollView.zoom(to: CGRect(x: x, y: y, width: width, height: height), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    @objc private func onLongPress(_ press: UILongPressGestureRecognizer) {
        if press.state == .began {
            longPressedAction?(self, press)
        }
    }
    
    /// 計算拖曳時圖片應調整的frame和scale值
    private func panResult(_ pan: UIPanGestureRecognizer) -> (frame: CGRect, scale: CGFloat) {
        let translation = pan.translation(in: scrollView)
        let currentTouch = pan.location(in: scrollView)
        
        // 由下拉的偏移值決定縮放比例，越往下偏移，縮得越小。 scale值區間[0.3, 1.0]
        let scale = min(1.0, max(0.3, 1 - translation.y / bounds.height))
        
        let width = beganFrame.size.width * scale
        let height = beganFrame.size.height * scale
        
        // 計算x和y。保持手指在圖片上的相對位置不變。
        // 即如果手勢開始時，手指在圖片X軸三分之一處，那麼在移動圖片時，保持手指始終位於圖片X軸的三分之一處
        let xRate = (beganTouch.x - beganFrame.origin.x) / beganFrame.size.width
        let currentTouchDeltaX = xRate * width
        let x = currentTouch.x - currentTouchDeltaX
        
        let yRate = (beganTouch.y - beganFrame.origin.y) / beganFrame.size.height
        let currentTouchDeltaY = yRate * height
        let y = currentTouch.y - currentTouchDeltaY
        
        return (CGRect(x: x.isNaN ? 0 : x, y: y.isNaN ? 0 : y, width: width, height: height), scale)
    }
}
