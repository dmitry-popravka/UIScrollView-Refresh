//
//  PDVRefresh.swift
//  PDVRefresh
//
//  Created by Dmitry on 18.10.17.
//  Copyright © 2017 Dmitry Popravka. All rights reserved.
//

import UIKit

extension UIScrollView {
    
    private struct AssociatedKeys {
        static var header = "header"
        static var footer = "footer"
    }
    
   weak var header: UIRefreshControl? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.header) as? UIRefreshControl
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.header, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    weak var footer: RefreshFooterControl? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.footer) as? RefreshFooterControl
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.footer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    //MARK: -
    //MARK: footer
    
    func addFooter(withTarget target: Any, action: Selector) {
        
        if let _ = footer {
            removeFooter()
        }
        
        footer = RefreshFooterControl(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: bounds.width,
                                                    height: RefreshFooterControl.height()))
        
        footer?.autoresizingMask = [UIViewAutoresizing.flexibleLeftMargin,
                                    UIViewAutoresizing.flexibleRightMargin]
        
        footer?.addTarget(target, action: action, for: .valueChanged)
        addSubview(footer!)
    }
  
    func footerBeginRefreshing() {
        if let footer = footer {
            
            let upOffset: CGFloat = max(0,
                                        (contentSize.height - bounds.height))
            
            setContentOffset(CGPoint(x: 0,
                                     y: upOffset + RefreshFooterControl.triggerHeight()),
                             animated: true)
            
            footer.beginRefreshing()
        }
    }
    
    func footerEndRefreshing() {
        footer?.endRefreshing()
    }
    
    func removeFooter() {
        footer?.removeFromSuperview()
        footer = nil
    }
    
    //MARK: -
    //MARK: footer
    
    func addHeader(withTarget target: Any, action: Selector) {
        
        if let _ = header {
            removeHeader()
        }
        
        let refresh = UIRefreshControl()
        refresh.addTarget(target, action: action, for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            refreshControl = refresh
        } else {
            addSubview(refresh)
        }
        
        alwaysBounceVertical = true
        header = refresh
    }
    
    func headerBeginRefreshing() {
                
        if let refresh = header, !refresh.isRefreshing {

            let contentOffsetY: CGFloat = {
                return -refresh.frame.size.height
            }()

            setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)

            refresh.beginRefreshing()
            refresh.sendActions(for: .valueChanged)
        }
    }
    
    func headerEndRefreshing() {
         header?.endRefreshing()
    }
    
    func removeHeader() {
        header?.removeFromSuperview()
    }
    
}

// MARK: - RefreshFooterControl
class RefreshFooterControl: UIControl {
    
    var acv: UIActivityIndicatorView
    var scrollView: UIScrollView?
    var refreshing: Bool
    
    override init(frame: CGRect) {
        
        refreshing = true
        
        acv = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        acv.frame = CGRect(x: frame.width/2 - frame.height/2,
                           y: 0,
                           width: frame.height,
                           height: frame.height)
        
        super.init(frame: frame)
        
        addSubview(acv)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func height() -> CGFloat {
        return 44
    }
    
    static func triggerHeight() -> CGFloat {
        return height() + 20
    }
    
    static func beginRefreshHeight() -> CGFloat {
        return 700
    }
    
    func beginRefreshing() {
        refreshing = true
        acv.startAnimating()
    }
    
    func endRefreshing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.refreshing = false
            self.acv.stopAnimating()
        }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        self.scrollView?.contentInset = UIEdgeInsets(top: 0,
                                                                     left: 0,
                                                                     bottom: 0,
                                                                     right: 0)
        }, completion: nil)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        endRefreshing()
        
        scrollView?.removeObserver(self,
                                   forKeyPath: "contentSize",
                                   context: nil)
        scrollView?.removeObserver(self,
                                   forKeyPath: "contentOffset",
                                   context: nil)
        
        if let newSuperview = newSuperview as? UIScrollView {
            newSuperview.addObserver(self,
                                     forKeyPath: "contentSize",
                                     options: .new,
                                     context: nil)
            newSuperview.addObserver(self,
                                     forKeyPath: "contentOffset",
                                     options: .new,
                                     context: nil)
            self.scrollView = newSuperview
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath,
            let scrollView = scrollView else {
                return
        }
        
        if !isUserInteractionEnabled || alpha <= 0.01 || isHidden {
            return
        }
        
        switch keyPath {
        case "contentSize":
            adjustFrameWithContentSize()
        case "contentOffset":
            
            if scrollView.contentOffset.y <= 0 {
                return
            }
            
            if (scrollView.contentOffset.y + scrollView.frame.size.height) > (scrollView.contentSize.height - RefreshFooterControl.beginRefreshHeight() + RefreshFooterControl.triggerHeight() ) && !refreshing {
                
                beginRefreshing()
                
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               options: .curveEaseIn,
                               animations: {
                                
                                self.scrollView?.contentInset = UIEdgeInsets(top: 0,
                                                                             left: 0,
                                                                             bottom: RefreshFooterControl.height(),
                                                                             right: 0)
                }, completion: nil)
                
                sendActions(for: .valueChanged)
            }
            
        default:
            return
        }
    }
    
    private func adjustFrameWithContentSize() {
        
        guard let scrollView = scrollView else { return }
        
        let contentHeight = scrollView.contentSize.height
        let scrollHeight = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        
        self.frame.origin.y = max(contentHeight, scrollHeight)
    }
    
}
