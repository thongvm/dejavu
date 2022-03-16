//
//  ViewController.swift
//  dejavu
//
//  Created by thongvm on 15/03/2022.
//

import UIKit
import Combine
import PromiseKit

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
        self.getData()
    }
    
    func setupUI() {
        
    }
    
    func getData() {
        var p: [Promise<ActivityModel>] = []
        
        // create all promises
        self.types.forEach { type in
            for _ in 0..<5 {
                p.append(makeRequest(type: type))
            }
        }
        
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
            
        }.catch { error in
            dump(error)
        }.finally {
        
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

