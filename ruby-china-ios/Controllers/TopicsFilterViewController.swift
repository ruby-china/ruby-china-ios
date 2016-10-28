//
//  TopicsFilterViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/22.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import SwiftyJSON

class TopicsFilterViewController: UIViewController {
    
    enum NodeData {
        case listType(TopicsService.ListType)
        case node(id: Int, name: String)
        
        func getName() -> String {
            switch self {
            case let .listType(type):
                switch type {
                case .last_actived  : return "default".localized
                case .recent        : return "type recent".localized
                case .no_reply      : return "type no reply".localized
                case .popular       : return ""
                case .excellent     : return "type excellent".localized
                }
            case let .node(_, name):
                return name
            }
        }
    }
    
    var selectedData: NodeData?
    var onChangeSelect: ((TopicsFilterViewController) -> ())?
    var onCancel: ((TopicsFilterViewController) -> ())?
    
    private struct GroupData {
        let name: String
        let nodes: [NodeData]
    }
    
    private let headerIdentifier = "HEADERVIEW"
    private let cellIdentifier = "NODECELL"
    private let cacheNodesJSONKey = "cacheNodesJSONKey"
    private var groupDatas = [GroupData]()
    private var parentWindow: UIWindow?

    private lazy var closeButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(close), forControlEvents: .TouchUpInside)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let colNumber: CGFloat = 4
        let cellMargin: CGFloat = 10
        let cellWidth = (self.view.bounds.size.width - (colNumber + 1) * cellMargin) / colNumber
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: floor(cellWidth), height: 30)
        layout.minimumLineSpacing = cellMargin
        layout.minimumInteritemSpacing = cellMargin
        layout.sectionInset = UIEdgeInsets(top: cellMargin, left: cellMargin, bottom: cellMargin, right: cellMargin)
        layout.headerReferenceSize = CGSize(width: self.view.bounds.size.width, height: 30)
        
        let view = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        view.registerClass(TopicsFilterNodeCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        view.registerClass(TopicsFilterNodeSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier)
        return view
    }()
    
    private lazy var cellSelectedImage: UIImage? = {
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return UIImage.roundedCorner(imageSize: cellSize, radius: 5, backgroundColor: NAVBAR_BG_COLOR, borderWidth: 0, borderColor: NAVBAR_BG_COLOR)
    }()
    private lazy var cellNormalImage: UIImage? = {
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return UIImage.roundedCorner(imageSize: cellSize, radius: 5, backgroundColor: UIColor.clearColor(), borderWidth: 1, borderColor: SEGMENT_BG_COLOR)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(closeButton)
        view.addSubview(collectionView)
        closeButton.snp_makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(64)
        }
        collectionView.snp_makeConstraints { (make) in
            make.top.equalTo(closeButton.snp_bottom)
            make.left.bottom.right.equalToSuperview()
        }
        
        initGroupDatas()
        
        if let jsonString = NSUserDefaults.standardUserDefaults().valueForKey(cacheNodesJSONKey) as? String {
            let json = JSON.parse(jsonString)
            if let nodes = nodesFromJSON(json) {
                addGroupDatas(nodes: nodes, isSync: true)
            }
        }
        
        loadNodes()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension TopicsFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return groupDatas.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupDatas[section].nodes.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerIdentifier, forIndexPath: indexPath) as! TopicsFilterNodeSectionHeaderView
            view.name = groupDatas[indexPath.section].name
            return view
        }
        return UICollectionReusableView()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let node = groupDatas[indexPath.section].nodes[indexPath.item]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! TopicsFilterNodeCell
        cell.normalImage = cellNormalImage
        cell.selectedImage = cellSelectedImage
        cell.name = node.getName()
        cell.selected = selectedData == nil ? false : node == selectedData!
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let node = groupDatas[indexPath.section].nodes[indexPath.item]
        selectedData = node
        onChangeSelect?(self)
    }
    
}

// MARK: - public

extension TopicsFilterViewController {
    
    static func show() -> TopicsFilterViewController {
        let vc = TopicsFilterViewController()
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.rootViewController = vc
        window.windowLevel = UIWindowLevelAlert
        window.makeKeyAndVisible()
        window.alpha = 0
        UIView.animateWithDuration(0.3, animations: {
            window.alpha = 1
        })
        
        vc.parentWindow = window
        
        return vc
    }
    
    func close() {
        UIView.animateWithDuration(0.3, animations: {
            self.parentWindow!.alpha = 0
            }, completion: { _ in
                self.parentWindow = nil
        })
    }
}

// MARK: - private

extension TopicsFilterViewController {
    
    private func initGroupDatas() {
        let nodes = [
            NodeData.listType(.last_actived),
            NodeData.listType(.excellent),
            NodeData.listType(.no_reply),
            NodeData.listType(.recent),
        ]
        groupDatas.append(GroupData(name: "all topics".localized, nodes: nodes))
    }
    
    private func loadNodes() {
        NodesService.list { [weak self] (response, result) in
            guard let `self` = self, result = result else {
                return
            }
            
            if let nodes = self.nodesFromJSON(result) where nodes.count > 0 {
                NSUserDefaults.standardUserDefaults().setValue(result.rawString(), forKey: self.cacheNodesJSONKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.addGroupDatas(nodes: nodes, isSync: false)
            }
        }
    }
    
    private func nodesFromJSON(json: JSON) -> [Node]? {
        guard let nodeList = json["nodes"].array where nodeList.count > 0 else {
            return nil
        }
        var nodes = [Node]()
        for nodeJSON in nodeList {
            nodes.append(Node(json: nodeJSON))
        }
        return nodes
    }
    
    private func addGroupDatas(nodes nodes: [Node], isSync: Bool) {
        if nodes.count <= 0 {
            return
        }
        
        let selectedData = self.selectedData
        var scrollToIndexPath: NSIndexPath?
        var nodeGroupDatas = [GroupData]()
        
        func sortAndCreateNodeGroupDatas() {
            let sortNodes = nodes.sort {
                $0.sectionName != $1.sectionName ? $0.sectionName < $1.sectionName : $0.name < $1.name
            }
            
            var nodeList = [NodeData]()
            var prevSectionName = sortNodes.first!.sectionName
            for node in sortNodes {
                if node.sectionName != prevSectionName {
                    nodeGroupDatas.append(GroupData(name: prevSectionName, nodes: nodeList))
                    nodeList = [NodeData]()
                    prevSectionName = node.sectionName
                }
                
                let nodeData = NodeData.node(id: node.id, name: node.name)
                if scrollToIndexPath == nil && selectedData != nil && selectedData! == nodeData {
                    scrollToIndexPath = NSIndexPath(forItem: nodeList.count, inSection: nodeGroupDatas.count + 1)
                }
                nodeList.append(nodeData)
            }
            if nodeList.count > 0 {
                nodeGroupDatas.append(GroupData(name: prevSectionName, nodes: nodeList))
            }
        }
        
        func displayNodeGroupDatas() {
            self.groupDatas = [self.groupDatas[0]] + nodeGroupDatas
            self.collectionView.reloadData()
            if let indexPath = scrollToIndexPath {
                self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredVertically, animated: false)
            }
        }
        
        if isSync {
            sortAndCreateNodeGroupDatas()
            displayNodeGroupDatas()
        } else {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                sortAndCreateNodeGroupDatas()
                dispatch_async(dispatch_get_main_queue()) {
                    displayNodeGroupDatas()
                }
            }
        }
    }
    
}

// MARK: - 重载运算符

func ==(v1: TopicsFilterViewController.NodeData, v2: TopicsFilterViewController.NodeData) -> Bool {
    switch (v1, v2) {
    case let (.listType(type1), .listType(type2)) where type1 == type2:
        return true
    case let (.node(id1, _), .node(id2, _)) where id1 == id2:
        return true
    default: return false
    }
}
