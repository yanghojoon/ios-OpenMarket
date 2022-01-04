import Foundation

enum JSONParser<Element: Codable> {
    static func decode(from data: Data) throws -> Element {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let data = try decoder.decode(Element.self, from: data)
        return data
    }
    
    static func encode(from element: Element) throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let data = try encoder.encode(element)
        return data
    }
}
