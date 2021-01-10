//
//  FlowLayout.swift
//  Social Break
//
//  Created by Matthew Mech on 1/1/21.
//

import Foundation
import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    let cellsPerRow: Int
    
    init(cellsPerRow: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerRow = cellsPerRow
        super.init()
        
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
}

class FadingLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {
    
    //should be 0<fade<1
    private let fadeFactor: CGFloat = 0.5
    private let cellHeight : CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(scrollDirection: UICollectionView.ScrollDirection) {
        super.init()
        self.scrollDirection = scrollDirection
        
    }
    
    override func prepare() {
        setupLayout()
        super.prepare()
    }
    
    func setupLayout() {
        self.itemSize = CGSize(width: self.collectionView!.bounds.size.width,height:cellHeight)
        self.minimumLineSpacing = 0
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    func scrollDirectionOver() -> UICollectionView.ScrollDirection {
        return UICollectionView.ScrollDirection.vertical
    }
    //this will fade both top and bottom but can be adjusted
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributesSuper: [UICollectionViewLayoutAttributes] = (super.layoutAttributesForElements(in: rect))!
        if let attributes = NSArray(array: attributesSuper, copyItems: true) as? [UICollectionViewLayoutAttributes]{
            var visibleRect = CGRect()
            visibleRect.origin = collectionView!.contentOffset
            visibleRect.size = collectionView!.bounds.size
            for attrs in attributes {
                if attrs.frame.intersects(rect) {
                    let distance = visibleRect.midY - attrs.center.y
                    let normalizedDistance = abs(distance) / (visibleRect.height * fadeFactor)
                    let fade = 1 - normalizedDistance
                    attrs.alpha = fade
                }
            }
            return attributes
        }else{
            return nil
        }
    }
    //appear and disappear at 0
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: itemIndexPath)! as UICollectionViewLayoutAttributes
        attributes.alpha = 0
        return attributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: itemIndexPath)! as UICollectionViewLayoutAttributes
        attributes.alpha = 0
        return attributes
    }
}

extension UICollectionView {
    
    func fadeEdges(with modifier: CGFloat) {
        
        let visibleCells = self.visibleCells
        
        guard !visibleCells.isEmpty else { return }
        guard let topCell = visibleCells.first else { return }
        guard let bottomCell = visibleCells.last else { return }
        
        visibleCells.forEach {
            $0.contentView.alpha = 1
        }
        
        let cellHeight = topCell.frame.height - 1
        let tableViewTopPosition = self.frame.origin.y
        let tableViewBottomPosition = self.frame.maxY
        
        guard let topCellIndexpath = self.indexPath(for: topCell) else { return }
        let theAttributesTop = self.layoutAttributesForItem(at: topCellIndexpath)
        let cellFrameInSuperviewTop = self.convert(theAttributesTop!.frame, to: self.superview)
        
        guard let bottomCellIndexpath = self.indexPath(for: bottomCell) else { return }
        let theAttributesBottom = self.layoutAttributesForItem(at: bottomCellIndexpath)
        let cellFrameInSuperviewBottom = self.convert(theAttributesBottom!.frame, to: self.superview)
        
        let topCellPosition = self.convert(cellFrameInSuperviewTop, to: self.superview).origin.y
        let bottomCellPosition = self.convert(cellFrameInSuperviewBottom, to: self.superview).origin.y + cellHeight
        let topCellOpacity = (1.0 - ((tableViewTopPosition - topCellPosition) / cellHeight) * modifier)
        let bottomCellOpacity = (1.0 - ((bottomCellPosition - tableViewBottomPosition) / cellHeight) * modifier)
        
        topCell.contentView.alpha = topCellOpacity
        bottomCell.contentView.alpha = bottomCellOpacity
    }
    
}
