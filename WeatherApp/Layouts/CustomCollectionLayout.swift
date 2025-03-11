//
//  CustomCollectionLayout.swift
//  WeatherApp
//
//  Created by Ani Lakirbaia on 09.02.25.
//
import UIKit

class CustomCollectionLayout: UICollectionViewFlowLayout {
    
    private let itemScaleFactor: CGFloat = 0.8
    private let itemWidth: CGFloat = 400
    private let itemHeight: CGFloat = 700
    private let spacing: CGFloat = 9
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        let collectionViewWidth = collectionView.bounds.width
        let sideInset = (collectionViewWidth - itemWidth) / 2

        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.minimumLineSpacing = spacing
        self.scrollDirection = .horizontal
        self.sectionInset = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
              let attributesArray = super.layoutAttributesForElements(in: rect)?.map({ $0.copy() as! UICollectionViewLayoutAttributes }) else {
            return nil
        }

        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let centerX = visibleRect.midX
        
        for attributes in attributesArray {
            let distanceFromCenter = abs(attributes.center.x - centerX)
            let scale = max(1 - (distanceFromCenter / collectionView.bounds.width) * (1 - itemScaleFactor), itemScaleFactor)
            
           
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
            attributes.alpha = scale
        }
        
        return attributesArray
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                      withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }

     
        let collectionViewCenter = proposedContentOffset.x + collectionView.bounds.width / 2
        
        
        let closestAttribute = super.layoutAttributesForElements(in: collectionView.bounds)?
            .min(by: { abs($0.center.x - collectionViewCenter) < abs($1.center.x - collectionViewCenter) })
        
     
        return CGPoint(x: (closestAttribute?.center.x ?? proposedContentOffset.x) - collectionView.bounds.width / 2,
                       y: proposedContentOffset.y)
    }
}
