//
//  LN_FlipView.swift
//  Ln_ry
//
//  Created by mxc235 on 2019/9/12.
//  Copyright © 2019 Lncir. All rights reserved.
//

import UIKit


let K_SCREEN_WIDTH = UIScreen.main.bounds.width
let K_SCREEN_HEIGHT = UIScreen.main.bounds.height
let K_STATUSBAR_HRIGHT:CGFloat = 64.0
let K_SCELL = "SegmentCell"
let K_CCELL = "ContenCEll"

let animationDuration:CGFloat = 0.2
let segmentTitilePadding:CGFloat = 10.0

@objc protocol LN_FlipViewProtocol:NSObjectProtocol {
    @objc optional func flipView( flipView: LN_FlipView, didSelectSegment index: Int)
}

class LN_FlipView: UIView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    var viewControllers: [UIViewController] = []
    var titles: [String] = []
    var titleRect: [CGRect] = []
    
    var segmentCollectionView: UICollectionView?
    var contentCollectionView: UICollectionView?
    
    var segmentHeight:CGFloat = 80.0
    var fontSize = 14.0
    
    var segmentBackColor:UIColor = .black
    var segmentItemColor:UIColor = .black
    var segmentTitleColor:UIColor = .white
    var segmentSelectItemColor:UIColor = .white
    var segmentSelectTitleColor:UIColor = .black
    
    weak var delegate:LN_FlipViewProtocol?
    
    init(frame: CGRect,viewControllers: Array<UIViewController>,titles: Array<String>){
        
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = .white

        assert(viewControllers.count == titles.count, "controller's count must equal titles's count")
        self.viewControllers += viewControllers
        self.titles += titles
        
        for title in titles {
            let rect = self.sizeWithText(text: NSString(string: title), font: .systemFont(ofSize: 14), size: .zero)
            self.titleRect.append(rect)
        }
        
        self.setupSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubview() -> () {
        self.setSegmentCollectionView()
        self.setContentCollectionView()
        self.selectIndex(index: IndexPath.init(item: 0, section: 0))
    }
    
    private func setSegmentCollectionView() -> () {
        
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2)

        let segmentCollectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: K_SCREEN_WIDTH, height: segmentHeight),collectionViewLayout: layout)
        segmentCollectionView.backgroundColor = self.segmentBackColor
        segmentCollectionView.bounces = false
        segmentCollectionView.showsHorizontalScrollIndicator = false
        
        segmentCollectionView.delegate = self
        segmentCollectionView.dataSource = self
        
        self.addSubview(segmentCollectionView)
        segmentCollectionView.register(SegmentCell.classForCoder(), forCellWithReuseIdentifier: K_SCELL)
        self.segmentCollectionView = segmentCollectionView
    }
    
    private func setContentCollectionView() -> () {
        
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        
        let contentCollectionView = UICollectionView.init(frame: CGRect(x: 0, y: segmentHeight, width: K_SCREEN_WIDTH, height: K_SCREEN_HEIGHT - segmentHeight),collectionViewLayout: layout)
        contentCollectionView.bounces = false
        contentCollectionView.isPagingEnabled = true
        
        contentCollectionView.delegate = self
        contentCollectionView.dataSource = self
        contentCollectionView.backgroundColor = .gray
        
        self.addSubview(contentCollectionView)
        contentCollectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: K_CCELL)
        self.contentCollectionView = contentCollectionView
    }
    
    
    private func selectIndex(index:IndexPath) -> () {
        
        UIView.animate(withDuration: TimeInterval(animationDuration), animations: {
            self.contentCollectionView?.scrollToItem(at: index, at: UICollectionView.ScrollPosition.left, animated: false)
            self.segmentCollectionView?.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
            
        }) { (complete) in
            self.updateCellStatus(indexPath: index)
        }
    }
    
    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(self.segmentCollectionView) {
            let cell:SegmentCell = collectionView.dequeueReusableCell(withReuseIdentifier: K_SCELL, for: indexPath) as! SegmentCell
            cell.configContent(title: self.titles[indexPath.row], segmentTitleColor: self.segmentTitleColor, segmentItemColor: self.segmentItemColor)
            return cell
        }else{
            let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: K_CCELL, for: indexPath)
            let vc = self.viewControllers[indexPath.row]
            cell.addSubview(vc.view)
            return cell
        }
    }
    
    // MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(self.segmentCollectionView) {
            selectIndex(index: indexPath)
            self.delegate?.flipView?(flipView: self, didSelectSegment: indexPath.item)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isEqual(self.contentCollectionView) {
            let index = scrollView.contentOffset.x / self.frame.size.width
            let indexPath = IndexPath.init(item: Int(index), section: 0)
            selectIndex(index: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.isEqual(self.segmentCollectionView) {
            let rect = self.titleRect[indexPath.item]
            return CGSize(width: rect.size.width * 1.5 + 2 * segmentTitilePadding, height: 50)
        }else{
            return CGSize(width: self.frame.width, height: self.frame.height - segmentHeight)
        }
    }
    
    func updateCellStatus(indexPath:IndexPath) -> () {
        if let cell:SegmentCell = self.segmentCollectionView?.cellForItem(at: indexPath) as? SegmentCell {
            let cells = self.segmentCollectionView?.visibleCells as! [SegmentCell]
            
            for cell:SegmentCell in cells {
                cell.label?.backgroundColor = self.segmentItemColor
                cell.label?.textColor = self.segmentTitleColor
            }
            cell.label?.backgroundColor = self.segmentSelectItemColor
            cell.label?.textColor = self.segmentSelectTitleColor
        }
    }
    
    func sizeWithText(text: NSString, font: UIFont, size: CGSize) -> CGRect {
        let attributes = [NSAttributedString.Key.font: font]
        let option = NSStringDrawingOptions.usesLineFragmentOrigin
        let rect:CGRect = text.boundingRect(with: size, options: option, attributes: attributes, context: nil)
        return rect;
    }
}

class SegmentCell: UICollectionViewCell {
    var label:UILabel?
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        self.setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() -> () {
        
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        
        self.contentView.addSubview(label)
        self.label = label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let leftCon = NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: self.contentView, attribute: .left, multiplier: 1.0, constant: segmentTitilePadding)
        let rightCon = NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: self.contentView, attribute: .right, multiplier: 1.0, constant: -segmentTitilePadding)
        let centerCon = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1.0, constant: 0)
        let heightCon = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        label.layer.cornerRadius = 20.0
        label.layer.masksToBounds = true
        
        label.addConstraint(heightCon)
        self.contentView.addConstraints([leftCon,rightCon,centerCon])
    }
    
    func configContent(title:String,segmentTitleColor:UIColor,segmentItemColor:UIColor) -> () {
        self.label?.textColor = segmentTitleColor
        self.label?.backgroundColor = segmentItemColor
        self.label?.text = title
    }
}

