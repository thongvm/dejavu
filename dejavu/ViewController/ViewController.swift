//
//  ViewController.swift
//  dejavu
//
//  Created by thongvm on 15/03/2022.
//

import UIKit
import Combine
import PromiseKit
import MBProgressHUD

class ViewController: UIViewController {
    @IBOutlet weak var listView: UICollectionView!
    
    let dejavuAPI: DejavuAPI = .init()
    let types = ["education", "recreational", "social", "diy", "charity"]
    let count = 5
    
    var keys: [String] = []
    var disposables = Set<AnyCancellable>()
    var data: [String: [ActivityModel?]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getData()
    }
    
    func setupUI() {
        // listview registry header
        self.listView.register(ActivityHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ActivityHeader")
        self.listView.register(UINib(nibName: "ActivityHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ActivityHeader")
        
        // listview registry cell
        self.listView.register(ActivityCell.self, forCellWithReuseIdentifier: "ActivityCell")
        self.listView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellWithReuseIdentifier: "ActivityCell")
        
        // assign delegate & datasource
        self.listView.delegate = self
        self.listView.dataSource = self
    }
    
    func getData() {
        var p: [Promise<ActivityModel>] = []
        
        // create all promises
        self.types.forEach { type in
            for _ in 0..<5 {
                p.append(makeRequest(type: type))
            }
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // resolve promises
        firstly {
            when(resolved: p)
        }.done { arr in
            
            var objs = arr.map { result -> ActivityModel? in
                switch result {
                case .fulfilled(let activity):
                    return activity
                case .rejected( _):
                    return nil
                }
            }.filter { t -> Bool in
                return t != nil
            }
            
            // sort accessibility
            objs = objs.sorted {$0!.accessibility < $1!.accessibility }
            
            // group data
            let group = Dictionary(grouping: objs, by: { $0!.type })
            self.data = group
            
            // sort key
            let allKeys = Array(group.keys).sorted { $0 < $1 }
            self.keys = allKeys
            
            // reload data
            self.listView.reloadData()
            
        }.catch { error in
            dump(error)
        }.finally {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func makeRequest(type: String) -> Promise<ActivityModel> {
        return Promise { seal in
            dejavuAPI.getActivity(type:  type)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { value in
                      switch value {
                      case .failure:
                          seal.reject(DejavuError.network(desc: "Failed to load"))
                          break
                      case .finished:
                          break
                      }
                    },
                    receiveValue: {  activity in
                        seal.fulfill(activity)
                  })
                .store(in: &disposables)
        }
       
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = self.keys[section]
        return self.data[key]?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.listView.dequeueReusableCell(withReuseIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        let key = self.keys[indexPath.section]
        cell.render(model: self.data[key]![indexPath.row]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let header = self.listView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ActivityHeader", for: indexPath) as! ActivityHeader
            header.lbTitle.text = self.keys[indexPath.section].uppercased()
            return header
        default:
            return .init()
        }
        
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: self.view.frame.self.width - 20, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: self.view.frame.size.width, height: 50)
    }
}
