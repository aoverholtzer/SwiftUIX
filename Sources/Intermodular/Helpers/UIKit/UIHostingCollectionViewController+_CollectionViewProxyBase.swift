//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

extension UIHostingCollectionViewController: _CollectionViewProxyBase {
    var collectionViewContentSize: CGSize {
        collectionView.contentSize
    }
    
    var maximumCollectionViewCellSize: OptionalDimensions {
        var baseContentSize = collectionView.contentSize
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            if collectionViewLayout.scrollDirection == .vertical {
                if baseContentSize.width == 0, collectionView.frame.width > 0 {
                    baseContentSize.width = collectionView.frame.width - collectionView.contentInset.horizontal
                }
            } else if collectionViewLayout.scrollDirection == .horizontal {
                if baseContentSize.height == 0, collectionView.frame.height > 0 {
                    baseContentSize.height = collectionView.frame.height - collectionView.contentInset.vertical
                }
            }
        }
        
        let contentSize = CGSize(
            width: baseContentSize.width - ((collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.horizontal ?? 0),
            height: baseContentSize.height - ((collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionInset.vertical ?? 0)
        )
        
        var result = OptionalDimensions(
            width: max(floor(contentSize.width - 0.001), 0),
            height: max(floor(contentSize.height - 0.001), 0)
        )
        
        if result.width == 0 {
            result.width = AppKitOrUIKitView.layoutFittingExpandedSize.width
        }
        
        if result.height == 0 {
            result.height = AppKitOrUIKitView.layoutFittingExpandedSize.height
        }
        
        return result
    }
    
    public func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    public func scrollToTop(anchor: UnitPoint? = nil, animated: Bool = true) {
        collectionView.setContentOffset(.zero, animated: animated)
    }
    
    public func scrollToLast(anchor: UnitPoint? = nil, animated: Bool) {
        guard collectionView.numberOfSections > 0 else {
            return
        }
        
        let lastSection = collectionView.numberOfSections - 1
        
        guard collectionView.numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(
            item: collectionView.numberOfItems(inSection: lastSection) - 1,
            section: lastSection
        )
        
        if collectionView.contentSize.minimumDimensionLength == 0 {
            withoutAnimation {
                collectionView.setNeedsLayout()
                collectionView.layoutIfNeeded()
            }
            
            let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
            
            let newContentOffset = CGPoint(
                x: collectionView.contentOffset.x,
                y: max(-collectionView.contentInset.top, contentSize.height - (collectionView.bounds.size.height - collectionView.contentInset.bottom))
            )
            
            if collectionView.contentOffset != newContentOffset, newContentOffset.y >= 0 {
                collectionView.setContentOffset(newContentOffset, animated: animated)
            }
        } else {
            collectionView.scrollToItem(at: lastItemIndexPath, at: .init(anchor ?? .bottom), animated: animated)
        }
    }
    
    public func scrollTo<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id) else {
            return
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .init(anchor),
            animated: true
        )
    }
    
    public func scrollTo<ID: Hashable>(itemBefore id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id).map(collectionView.indexPath(before:)), collectionView.contains(indexPath) else {
            return
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .init(anchor),
            animated: true
        )
    }
    
    public func scrollTo<ID: Hashable>(itemAfter id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id).map(collectionView.indexPath(after:)), collectionView.contains(indexPath) else {
            return
        }
        
        collectionView.scrollToItem(
            at: indexPath,
            at: .init(anchor),
            animated: true
        )
    }
    
    public func select<ID: Hashable>(_ id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = indexPath(for: id) else {
            return
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func select<ID: Hashable>(itemBefore id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id).map(collectionView.indexPath(before:)), collectionView.contains(indexPath) else {
            return
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func select<ID: Hashable>(itemAfter id: ID, anchor: UnitPoint? = nil) {
        guard let indexPath = cache.firstIndexPath(for: id).map(collectionView.indexPath(after:)), collectionView.contains(indexPath) else {
            return
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func selectNextItem(anchor: UnitPoint?) {
        guard !configuration.allowsMultipleSelection else {
            assertionFailure("selectNextItem(anchor:) is unavailable when multiple selection is allowed.")
            
            return
        }
        
        guard let indexPathForSelectedItem = collectionView.indexPathsForSelectedItems?.first else {
            if let indexPath = collectionView.indexPathsForVisibleItems.sorted().first {
                collectionView.selectItem(
                    at: indexPath,
                    animated: true,
                    scrollPosition: .init(anchor)
                )
            }
            
            return
        }
        
        let indexPath = collectionView.indexPath(after: indexPathForSelectedItem)
        
        guard collectionView.contains(indexPath) else {
            return collectionView.deselectItem(at: indexPathForSelectedItem, animated: true)
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func selectPreviousItem(anchor: UnitPoint?) {
        guard !configuration.allowsMultipleSelection else {
            assertionFailure("selectPreviousItem(anchor:) is unavailable when multiple selection is allowed.")
            
            return
        }
        
        guard let indexPathForSelectedItem = collectionView.indexPathsForSelectedItems?.first else {
            if let indexPath = collectionView.indexPathsForVisibleItems.sorted().last {
                collectionView.selectItem(
                    at: indexPath,
                    animated: true,
                    scrollPosition: .init(anchor)
                )
            }
            
            return
        }
        
        let indexPath = collectionView.indexPath(before: indexPathForSelectedItem)
        
        guard collectionView.contains(indexPath) else {
            return collectionView.deselectItem(at: indexPathForSelectedItem, animated: true)
        }
        
        collectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .init(anchor)
        )
    }
    
    public func deselect<ID: Hashable>(_ id: ID) {
        guard let indexPath = indexPath(for: id) else {
            return
        }
        
        collectionView.deselectItem(
            at: indexPath,
            animated: true
        )
    }
    
    private func indexPath<ID: Hashable>(for id: ID) -> IndexPath? {
        cache.firstIndexPath(for: id)
    }
    
    public func selection<ID: Hashable>(for id: ID) -> Binding<Bool> {
        let indexPath = cache.firstIndexPath(for: id)
        
        return .init(
            get: { indexPath.flatMap({ [weak self] in self?.collectionView.cellForItem(at: $0)?.isSelected }) ?? false },
            set: { [weak self] newValue in
                guard let indexPath = indexPath else {
                    return
                }
                
                self?.collectionView.deselectItem(at: indexPath, animated: true)
            }
        )
    }
}

// MARK: - Auxiliary Implementation -

fileprivate extension UICollectionView {
    func contains(_ indexPath: IndexPath) -> Bool {
        guard indexPath.section < numberOfSections, indexPath.row >= 0, indexPath.row < numberOfItems(inSection: indexPath.section) else {
            return false
        }
        
        return true
    }
    
    func indexPath(before indexPath: IndexPath) -> IndexPath {
        IndexPath(row: indexPath.row - 1, section: indexPath.section)
    }
    
    func indexPath(after indexPath: IndexPath) -> IndexPath {
        IndexPath(row: indexPath.row + 1, section: indexPath.section)
    }
}

fileprivate extension UICollectionView.ScrollPosition {
    init(_ unitPoint: UnitPoint?) {
        switch (unitPoint ?? .zero) {
            case .zero:
                self = [.left, .top]
            case .center:
                self = [.centeredHorizontally, .centeredVertically]
            case .leading:
                self = [.left, .centeredVertically]
            case .trailing:
                self = [.right, .centeredVertically]
            case .top:
                self = [.centeredHorizontally, .top]
            case .bottom:
                self = [.centeredHorizontally, .bottom]
            case .topLeading:
                self = [.left, .top]
            case .topTrailing:
                self = [.right, .top]
            case .bottomLeading:
                self = [.right, .bottom]
            case .bottomTrailing:
                self = [.right, .bottom]
            default:
                assertionFailure()
                self = []
        }
    }
}

#endif
