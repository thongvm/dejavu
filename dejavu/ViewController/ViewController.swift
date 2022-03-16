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
    let dejavuAPI: DejavuAPI = .init()
    var disposables = Set<AnyCancellable>()
    
    let types = ["education", "recreational", "social", "diy", "charity"]
    let count = 5
    @Published var data: [[String: ActivityModel]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
    }
    
    func getData() {
        var p: [Promise<ActivityModel>] = []
        
        self.types.forEach { type in
            for _ in 0..<5 {
                p.append(makeRequest(type: type))
            }
        }
        
        firstly {
            when(resolved: p)
        }.done { arr in
            dump("length: \(arr.count)")
            dump(arr)
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

