//
//  DejavuAPI.swift
//  dejavu
//
//  Created by thongvm on 15/03/2022.
//

import Foundation
import Combine

protocol DejavuAPIProtocol {
    
    func getActivity(type: String) -> AnyPublisher<ActivityModel, DejavuError>
}

class DejavuAPI {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension DejavuAPI: DejavuAPIProtocol {
    
    func getActivity(type: String) -> AnyPublisher<ActivityModel, DejavuError> {
        return get(with: composeRequest(type: type))
    }
    
    func get<T>(with components: URLComponents) -> AnyPublisher<T, DejavuError> where T: Decodable {
        guard let url = components.url else {
            let error = DejavuError.network(desc: "Failed to create URL")
            return Fail(error: error).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                .network(desc: error.localizedDescription)
            }
            .flatMap(maxPublishers: .max(1)) { pair in
                self.decode(pair.data)
            }
            .eraseToAnyPublisher()
    }
    
    func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, DejavuError> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        return Just(data)
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                .parsing(desc: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}

extension DejavuAPI {
    
    func composeRequest(type: String) -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.boredapi.com"
        components.path = "/api/activity"
        
        components.queryItems = [
            URLQueryItem(name: "type", value: type),
        ]
        return components
    }
}
