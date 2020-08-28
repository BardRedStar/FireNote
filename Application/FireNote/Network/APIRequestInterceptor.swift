//
//  APIRequestInterceptor.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Alamofire
import Foundation
import Moya

/// A class, which represents the interceptor for Moya requests
class APIRequestInterceptor: RequestInterceptor {
    // MARK: - Definitions

    typealias UserCredentialsClosure = () -> UserCredentials?
    typealias DidFinishClosure = (APIToken) -> Void

    // MARK: - Properties and variables

//    private lazy var provider: MoyaProvider<AuthTarget> = {
//        var plugins: [PluginType] = []
//
//        #if DEBUG
//        let loggerPlugin = NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: [.verbose]))
//        plugins.append(loggerPlugin)
//        #endif
//
//        return MoyaProvider<AuthTarget>(plugins: plugins)
//    }()

    private let userCredentialsClosure: UserCredentialsClosure
    private let didFinishClosure: DidFinishClosure

    // MARK: - Initialization

    init(userCredentialsClosure: @escaping UserCredentialsClosure, didFinishClosure: @escaping DidFinishClosure) {
        self.userCredentialsClosure = userCredentialsClosure
        self.didFinishClosure = didFinishClosure
    }

    // MARK: - Interception methods

//    func retry(_ request: Request,
//               for session: Session,
//               dueTo error: Error,
//               completion: @escaping (RetryResult) -> Void) {
//        if let response = request.task?.response as? HTTPURLResponse,
//            response.statusCode == 401,
//            let userCredentials = userCredentialsClosure() {
//            var parameters = RequestParameters<LoginKey>()
//            parameters[.email] = userCredentials.email
//            parameters[.password] = userCredentials.password
//            provider.request(.token(parameters: parameters.parameters)) { [weak self] result in
//                guard let self = self else { return }
//
//                let result = APIManager.mapResult(result, to: APIToken.self)
//
//                switch result {
//                case let .success(decoded):
//                    self.didFinishClosure(decoded)
//                    completion(.retry)
//                case let .failure(error):
//                    completion(.doNotRetryWithError(error))
//                }
//            }
//        } else {
//            completion(.doNotRetry)
//        }
//    }
}
