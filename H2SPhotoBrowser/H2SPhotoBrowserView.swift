//
//  H2SPhotoBrowserView.swift
//  H2SPhotoBrowser
//
//  Created by jlai on 2023/11/24.
//

import UIKit

open class H2SPhotoBrowserView: UIView {
    open weak var photoBrowser: H2SPhotoBrowser?
    
    open var scrollDirection: H2SPhotoBrowser.ScrollDirection = .horizontal
    
    open var itemSpacing: CGFloat = 30
    
    open var pageIndex = 0 {
        didSet {
            if pageIndex != oldValue {
                isPageIndexChanged = true
            }
        }
        
    }
    
    open lazy var cellWillAppear: (H2SPhotoBrowserCell, Int) -> Void = { _, _ in }
    
    open lazy var cellWillDisappear: (H2SPhotoBrowserCell, Int) -> Void = { _, _ in }
    
    open lazy var cellDidAppear: (H2SPhotoBrowserCell, Int) -> Void = { _, _ in }
    
    open lazy var numberOfItems: () -> Int = { 0 }
    
    open lazy var cellClassAtIndex: (_ index: Int) -> H2SPhotoBrowserCell.Type = { _ in
        H2SPhotoBrowserImageCell.self
    }
    
    open lazy var reloadCellAtIndex: (H2SPhotoBrowser.ReloadCellContext) -> Void = { _ in }
    
    open lazy var didChangedPageIndex: (_ index: Int) -> Void = { _ in }
    
    open lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = .clear
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.isPagingEnabled = true
        sv.isScrollEnabled = true
        sv.delegate = self
        return sv
    }()
    
    var isRotating = false
    
    private var isPageIndexChanged = true
    
    private var visibleCells = [Int: H2SPhotoBrowserCell]()
    
    private var reusableCells = [String: [H2SPhotoBrowserCell]]()
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if scrollDirection == .horizontal {
            scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width + itemSpacing, height: bounds.height)
        } else {
            scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + itemSpacing)
        }
        reloadData()
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(scrollView)
    }
    
    private func resetContentSize() {
        let maxIndex = CGFloat(numberOfItems())
        if scrollDirection == .horizontal {
            scrollView.contentSize = CGSize(width: scrollView.frame.width * maxIndex,
                                            height: scrollView.frame.height)
        } else {
            scrollView.contentSize = CGSize(width: scrollView.frame.width,
                                            height: scrollView.frame.height * maxIndex)
        }
    }
    
    private func reloadData() {
        pageIndex = max(0, pageIndex)
        pageIndex = min(pageIndex, numberOfItems())
        resetContentSize()
        resetCells()
        layoutCells()
        reloadItems()
        refreshContentOffset()
    }
    
    private func refreshContentOffset() {
        if scrollDirection == .horizontal {
            scrollView.contentOffset = CGPoint(x: CGFloat(pageIndex) * scrollView.bounds.width, y: 0)
        } else {
            scrollView.contentOffset = CGPoint(x: 0, y: CGFloat(pageIndex) * scrollView.bounds.height)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isRotating {
            isRotating = false
            return
        }
        
        if scrollDirection == .horizontal && scrollView.bounds.width > 0  {
            pageIndex = Int(round(scrollView.contentOffset.x / (scrollView.bounds.width)))
        } else if scrollDirection == .vertical && scrollView.bounds.height > 0 {
            pageIndex = Int(round(scrollView.contentOffset.y / (scrollView.bounds.height)))
        }
        if isPageIndexChanged {
            isPageIndexChanged = false
            resetCells()
            layoutCells()
            reloadItems()
            didChangedPageIndex(pageIndex)
        }
    }
    
    private func enqueue(cell: H2SPhotoBrowserCell) {
        let name = String(describing: cell.classForCoder)
        if var array = reusableCells[name] {
            array.append(cell)
            reusableCells[name] = array
        } else {
            reusableCells[name] = [cell]
        }
    }
    
    private func dequeue(cellType: H2SPhotoBrowserCell.Type, browser: H2SPhotoBrowser) -> H2SPhotoBrowserCell {
        var cell: H2SPhotoBrowserCell
        let name = String(describing: cellType.classForCoder())
        if var array = reusableCells[name], array.count > 0 {
            cell = array.removeFirst()
            reusableCells[name] = array
        } else {
            cell = cellType.generate(with: browser)
        }
        return cell
    }
    
    private func resetCells() {
        guard let browser = photoBrowser else {
            return
        }
        var removeFromVisibles = [Int]()
        for (index, cell) in visibleCells {
            if index == pageIndex {
                continue
            }
            cellWillDisappear(cell, index)
            cell.removeFromSuperview()
            enqueue(cell: cell)
            removeFromVisibles.append(index)
        }
        removeFromVisibles.forEach { visibleCells.removeValue(forKey: $0) }
        
        let itemsTotalCount = numberOfItems()
        for index in (pageIndex - 1)...(pageIndex + 1) {
            if index < 0 || index > itemsTotalCount - 1 {
                continue
            }
            if index == pageIndex && visibleCells[index] != nil {
                continue
            }
            let clazz = cellClassAtIndex(index)
            let cell = dequeue(cellType: clazz, browser: browser)
            visibleCells[index] = cell
            scrollView.addSubview(cell)
        }
    }
    
    private func layoutCells() {
        let cellWidth = bounds.width
        let cellHeight = bounds.height
        for (index, cell) in visibleCells {
            if scrollDirection == .horizontal {
                cell.frame = CGRect(x: CGFloat(index) * (cellWidth + itemSpacing), y: 0, width: cellWidth, height: cellHeight)
            } else {
                cell.frame = CGRect(x: 0, y: CGFloat(index) * (cellHeight + itemSpacing), width: cellWidth, height: cellHeight)
            }
        }
    }
    
    private func reloadItems() {
        visibleCells.forEach { [weak self] index, cell in
            guard let `self` = self else { return }
            self.reloadCellAtIndex((cell, index, self.pageIndex))
            cell.setNeedsLayout()
        }
        if let cell = visibleCells[pageIndex] {
            cellWillAppear(cell, pageIndex)
        }
    }

}

extension H2SPhotoBrowserView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let cell = visibleCells[pageIndex] {
            cellDidAppear(cell, pageIndex)
        }
    }
}
