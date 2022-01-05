import UIKit

enum NetworkTask {
    static let boundary = UUID().uuidString
    
    static func requestHealthChekcer(completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let url = NetworkAddress.healthChecker.url else { return }
        let request = URLRequest(url: url)
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    static func requestProductRegistration(identifier: String,
                                           salesInformation: SalesInformation,
                                           images: [String: Data],
                                           completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let url = NetworkAddress.productRegistration.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(identifier, forHTTPHeaderField: "identifier")
        request.addValue("multipart/form-data; boundary=\(boundary)",
                         forHTTPHeaderField: "Content-Type")
        let body = buildBody(with: salesInformation, images: images)
        request.httpBody = body
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    static func requestProductModification(identifier: String,
                                           productId: Int,
                                           information: ModificationInformation,
                                           completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let url = NetworkAddress.productModification(productId: productId).url else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(identifier, forHTTPHeaderField: "identifier")
        request.httpBody = try? JSONParser.encode(from: information)
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    static func requestProductDetail(productId: Int, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let url = NetworkAddress.productDetail(productId: productId).url else { return }
        let request = URLRequest(url: url)
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    static func requestProductList(pageNumber: Int,
                                   itemsPerPage: Int,
                                   completionHandler: @escaping (Result<Data, Error>) -> Void) {
        guard let url = NetworkAddress.productList(pageNumber: pageNumber, itemsPerPage: itemsPerPage).url else { return }
        let request = URLRequest(url: url)
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    private static func dataTask(with request: URLRequest,
                                 completionHandler: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTask {
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completionHandler(.failure(NetworkError.requestFailed))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                      completionHandler(.failure(NetworkError.httpError))
                      return
                  }
            guard let data = data else { return }
            completionHandler(.success(data))
        }
        return dataTask
    }
    
    private static func buildBody(with salesInformation: SalesInformation,
                                  images: [String: Data]) -> Data? {
        guard let endBoundary = "\r\n--\(boundary)--".data(using: .utf8) else {
            return nil
        }
        guard let newLine = "\r\n".data(using: .utf8) else {
            return nil
        }
        guard let salesInformation = try? JSONParser.encode(from: salesInformation) else {
            return nil
        }
        var data = Data()
        var paramsBody = ""
        paramsBody.append("--\(boundary)\r\n")
        paramsBody.append("Content-Disposition: form-data; name=\"params\"\r\n\r\n")
        guard let paramsBody = paramsBody.data(using: .utf8) else {
            return nil
        }
        data.append(paramsBody)
        data.append(salesInformation)
        for (fileName, image) in images {
            var imagesBody = ""
            imagesBody.append("\r\n--\(boundary)\r\n")
            imagesBody.append("Content-Disposition: form-data; name=\"images\"; filename=\(fileName)\r\n")
            guard let imagesBody = imagesBody.data(using: .utf8) else {
                return nil
            }
            data.append(imagesBody)
            data.append(newLine)
            data.append(image)
        }
        data.append(endBoundary)
        return data
    }
}

extension NetworkTask {
    
    enum NetworkAddress {
        static let apiHost = "https://market-training.yagom-academy.kr"
        
        case healthChecker
        case productRegistration
        case productModification(productId: Int)
        case productDetail(productId: Int)
        case productList(pageNumber: Int, itemsPerPage: Int)
        
        var url: URL? {
            switch self {
            case .healthChecker:
                return URL(string: Self.apiHost + "/healthChecker")
            case .productRegistration:
                return URL(string: Self.apiHost + "/api/products")
            case .productModification(let productId):
                return URL(string: Self.apiHost + "/api/products/\(productId)")
            case .productDetail(let productId):
                return URL(string: Self.apiHost + "/api/products/" + String(productId))
            case .productList(let pageNumber, let itemsPerPage):
                var urlComponents = URLComponents(string: Self.apiHost + "/api/products?")
                let pageNumber = URLQueryItem(name: "page_no", value: String(pageNumber))
                let itemsPerPage = URLQueryItem(name: "items_per_page", value: String(itemsPerPage))
                urlComponents?.queryItems?.append(pageNumber)
                urlComponents?.queryItems?.append(itemsPerPage)
                return urlComponents?.url
            }
        }
    }
    
    struct SalesInformation: Codable {
        var name: String
        var descriptions: String
        var price: Double
        var currency: Currency
        var discountedPrice: Double?
        var stock: Int?
        var secret: String
    }
    
    struct ModificationInformation: Codable {
        var name: String?
        var descriptions: String?
        var thumbnail_id: Int?
        var price: Int?
        var currency: Currency?
        var discountedPrice: Double?
        var stock: Int?
        var secret: String
    }
}