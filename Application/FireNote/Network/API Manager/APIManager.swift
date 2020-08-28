//
//  APIManager.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Moya

/// Provides methods to perform requests over Moya
final class APIManager {
    // MARK: - Properties and variables

    /// Base URL built according to current environment
    static var basePath: String {
        return "https://mybackend.com/api"
    }

    /// Moya provider object
    lazy var provider: MoyaProvider<MultiTarget> = {
        let authPlugin = AccessTokenPlugin(tokenClosure: { _ in self.apiToken?.token ?? "" })
        var plugins: [PluginType] = [authPlugin]

        #if DEBUG
        let loggerPlugin = NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(logOptions: [.verbose]))
        plugins.append(loggerPlugin)
        #endif

        let configuration = URLSessionConfiguration.default
        configuration.headers = .default

        let userCredentialsClosure: APIRequestInterceptor.UserCredentialsClosure = { [weak self] in
            self?.defaultStorage.userCredentials
        }

        let didFinishClosure: APIRequestInterceptor.DidFinishClosure = { [weak self] token in
            self?.apiToken = token
        }

        let interceptor = APIRequestInterceptor(userCredentialsClosure: userCredentialsClosure, didFinishClosure: didFinishClosure)
        let session = Moya.Session(configuration: configuration, startRequestsImmediately: false, interceptor: interceptor)

        return MoyaProvider<MultiTarget>(session: session, plugins: plugins)
    }()

    static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let debugRetry = false

    var apiToken: APIToken? {
        didSet {
            if debugRetry {
                let wrongToken = "debug_retry"
                if apiToken?.token != wrongToken {
                    delay(30.0) { [weak self] in
                        guard let self = self, self.apiToken != nil else { return }
                        self.apiToken = APIToken(token: wrongToken)
                    }
                }
            }
        }
    }

    private var defaultStorage: DefaultStorage

    // MARK: - Initialization

    init(defaultStorage: DefaultStorage) {
        self.defaultStorage = defaultStorage
    }

    // MARK: - Common Methods

    /// Helper method that calls Moya target and performs mapResult to given decodable type
    @discardableResult
    func requestDecoded<T: Decodable>(_ target: TargetType,
                                      to type: T.Type,
                                      callbackQueue: DispatchQueue? = .none,
                                      progress: ProgressBlock? = .none,
                                      completion: @escaping (Result<T, APIError>) -> Void) -> Cancellable {
        return provider.request(MultiTarget(target), callbackQueue: callbackQueue, progress: progress) { result in
            let result = APIManager.mapResult(result, to: type)
            completion(result)
        }
    }

    /// Maps default Moya result type 'Result<Response, MoyaError>' to internal 'Result<Response, APIError>'
    /// by parsing BackendError formats from either success or faulure response if needed
    class func mapResult(_ result: Result<Response, MoyaError>) -> Result<Response, APIError> {
        switch result {
        case let .success(response):
            if response.statusCode >= 400 {
                return .failure(decodeBackendError(data: response.data))
            }
            return .success(response)
        case let .failure(error):
            if let response = error.response {
                return .failure(decodeBackendError(data: response.data))
            }
            return .failure(.moya(error))
        }
    }

    /// Maps default Moya result type 'Result<Response, MoyaError>' to concrete decodable 'Result<Decodable, APIError>'
    /// by parsing BackendError formats from either success or faulure response if needed, and by decoding response data
    /// to provided Decodable type
    class func mapResult<T: Decodable>(_ result: Result<Response, MoyaError>, to type: T.Type) -> Result<T, APIError> {
        switch result {
        case let .success(response):
            if response.statusCode >= 400 {
                return .failure(decodeBackendError(data: response.data))
            }

            do {
                let decoded = try decoder.decode(type.self, from: response.data)
                return .success(decoded)
            } catch {
                return .failure(.decoding(error))
            }
        case let .failure(error):
            if let response = error.response {
                return .failure(decodeBackendError(data: response.data))
            }
            return .failure(.moya(error))
        }
    }

    /// Performs the request with parameters and maps it into response typed object
    @discardableResult
    func request(_ target: TargetType,
                 callbackQueue: DispatchQueue? = .none,
                 progress: ProgressBlock? = .none,
                 completion: @escaping (Result<Response, APIError>) -> Void) -> Cancellable {
        return provider.request(MultiTarget(target),
                                callbackQueue: callbackQueue, progress: progress) { result in
            let result = APIManager.mapResult(result)
            completion(result)
        }
    }

    // MARK: - Private

    private class func decodeBackendError(data: Data) -> APIError {
        do {
            let backendError = try BackendError.decodeError(from: data, decoder: decoder)
            return .backend(backendError)
        } catch {
            return .decoding(error)
        }
    }
}
