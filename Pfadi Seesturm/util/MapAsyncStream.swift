//
//  MapAsyncStream.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.05.2025.
//

extension AsyncStream {
    
    func map<Transformed>(
        _ transform: @escaping (Element) -> Transformed
    ) -> AsyncStream<Transformed> {
        var iterator = self.makeAsyncIterator()
        return AsyncStream<Transformed> {
            guard let value = await iterator.next() else { return nil }
            return transform(value)
        }
    }
}
