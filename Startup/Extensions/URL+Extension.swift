//
//  URL+Extension.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/14/24.
//

import Foundation

extension URL {
    func param(_ param: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
