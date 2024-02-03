import Foundation
import Libcore

extension LibboxStringIteratorProtocol {
    func toArray() -> [String] {
        var array: [String] = []
        while hasNext() {
            array.append(next())
        }
        return array
    }
}
