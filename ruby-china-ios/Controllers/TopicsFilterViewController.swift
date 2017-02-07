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
    
    fileprivate struct GroupData {
        let name: String
        let nodes: [NodeData]
    }
    
    fileprivate let headerIdentifier = "HEADERVIEW"
    fileprivate let cellIdentifier = "NODECELL"
    fileprivate let cacheNodesJSONKey = "cacheNodesJSONKey"
    fileprivate var groupDatas = [GroupData]()
    fileprivate var parentWindow: UIWindow?

    fileprivate lazy var closeButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(close), for: .touchUpInside)
        return view
    }()
    
    fileprivate lazy var collectionView: UICollectionView = {
        let colNumber: CGFloat = 4
        let cellMargin: CGFloat = 10
        let cellWidth = (self.view.bounds.size.width - (colNumber + 1) * cellMargin) / colNumber
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: floor(cellWidth), height: 30)
        layout.minimumLineSpacing = cellMargin
        layout.minimumInteritemSpacing = cellMargin
        layout.sectionInset = UIEdgeInsets(top: cellMargin, left: cellMargin, bottom: cellMargin, right: cellMargin)
        layout.headerReferenceSize = CGSize(width: self.view.bounds.size.width, height: 30)
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
        view.register(TopicsFilterNodeCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        view.register(TopicsFilterNodeSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerIdentifier)
        return view
    }()
    
    fileprivate lazy var cellSelectedImage: UIImage? = {
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return UIImage.roundedCorner(imageSize: cellSize, radius: 5, backgroundColor: NAVBAR_BG_COLOR, borderWidth: 0, borderColor: NAVBAR_BG_COLOR)
    }()
    fileprivate lazy var cellNormalImage: UIImage? = {
        let cellSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return UIImage.roundedCorner(imageSize: cellSize, radius: 5, backgroundColor: UIColor.clear, borderWidth: 1, borderColor: SEGMENT_BG_COLOR)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(closeButton)
        view.addSubview(collectionView)
        closeButton.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(64)
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(closeButton.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        
        initGroupDatas()
        
        if let jsonString = UserDefaults.standard.value(forKey: cacheNodesJSONKey) as? String {
            let json = JSON(parseJSON: jsonString)
            if let nodes = nodesFromJSON(json) {
                addGroupDatas(nodes: nodes, isSync: true)
            }
        }
        
        loadNodes()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension TopicsFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groupDatas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupDatas[section].nodes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! TopicsFilterNodeSectionHeaderView
            view.name = groupDatas[(indexPath as NSIndexPath).section].name
            return view
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let node = groupDatas[(indexPath as NSIndexPath).section].nodes[(indexPath as NSIndexPath).item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TopicsFilterNodeCell
        cell.normalImage = cellNormalImage
        cell.selectedImage = cellSelectedImage
        cell.name = node.getName()
        cell.isSelected = selectedData == nil ? false : node == selectedData!
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let node = groupDatas[(indexPath as NSIndexPath).section].nodes[(indexPath as NSIndexPath).item]
        selectedData = node
        onChangeSelect?(self)
    }
    
}

// MARK: - public

extension TopicsFilterViewController {
    
    static func show() -> TopicsFilterViewController {
        let vc = TopicsFilterViewController()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = vc
        window.windowLevel = UIWindowLevelAlert
        window.makeKeyAndVisible()
        window.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            window.alpha = 1
        })
        
        vc.parentWindow = window
        
        return vc
    }
    
    func close() {
        UIView.animate(withDuration: 0.3, animations: {
            self.parentWindow!.alpha = 0
            }, completion: { _ in
                self.parentWindow = nil
        })
    }
}

// MARK: - private

extension TopicsFilterViewController {
    
    fileprivate func initGroupDatas() {
        let nodes = [
            NodeData.listType(.last_actived),
            NodeData.listType(.excellent),
            NodeData.listType(.no_reply),
            NodeData.listType(.recent),
        ]
        groupDatas.append(GroupData(name: "all topics".localized, nodes: nodes))
    }
    
    fileprivate func loadNodes() {
        NodesService.list { [weak self] (response, result) in
            guard let `self` = self, let result = result else {
                return
            }
            
            if let nodes = self.nodesFromJSON(result) , nodes.count > 0 {
                UserDefaults.standard.setValue(result.rawString(), forKey: self.cacheNodesJSONKey)
                UserDefaults.standard.synchronize()
                
                self.addGroupDatas(nodes: nodes, isSync: false)
            }
        }
    }
    
    fileprivate func nodesFromJSON(_ json: JSON) -> [Node]? {
        guard let nodeList = json["nodes"].array , nodeList.count > 0 else {
            return nil
        }
        var nodes = [Node]()
        for nodeJSON in nodeList {
            nodes.append(Node(json: nodeJSON))
        }
        return nodes
    }
    
    fileprivate func addGroupDatas(nodes: [Node], isSync: Bool) {
        if nodes.count <= 0 {
            return
        }
        
        let selectedData = self.selectedData
        var scrollToIndexPath: IndexPath?
        var nodeGroupDatas = [GroupData]()
        
        func sortAndCreateNodeGroupDatas() {
            let sortNodes = nodes.sorted {
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
                    scrollToIndexPath = IndexPath(item: nodeList.count, section: nodeGroupDatas.count + 1)
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
                self.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            }
        }
        
        if isSync {
            sortAndCreateNodeGroupDatas()
            displayNodeGroupDatas()
        } else {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                sortAndCreateNodeGroupDatas()
                DispatchQueue.main.async {
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
