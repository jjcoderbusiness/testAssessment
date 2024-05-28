//
//  ListViewModel.swift
//  Task
//
//  Created by Jagdish Jangir on 28/05/24.
//

import Foundation
import Combine


class ListViewModel {
    
    private(set) var data: [ListItem] = []
    private(set) var currentPage: UInt = 0
    
    private var itemDetails: [String : String] = [:]
    
    let limit: UInt = 20
    
    func fetchNextPageData() async throws -> Int {
        do {
            let result = try await ServerConnect.shared.fetchData(page: currentPage + 1, postLimit: limit)
            guard !result.isEmpty else {return 0}
            currentPage = currentPage + 1 // Update current page only if there is new data
            self.data.append(contentsOf: result)
            return result.count
        }catch {
            throw error
        }
    }
    
    func selectedItemDetails(_ selectedItem: ListItem?) -> String? {
        guard selectedItem != nil else {return nil}
        let idVal = "\(selectedItem?.userId ?? 0)\(selectedItem?.id ?? 0)"
        if let text = itemDetails[idVal] {
            return text
        }
        var text  = ""
        text.append("UserId: \(selectedItem?.userId ?? 0)\n\n")
        text.append("PostId: \(selectedItem?.id ?? 0)\n\n")
        text.append("Title:\n \(selectedItem?.title ?? "")\n\n")
        text.append("Body:\n \(selectedItem?.body ?? "")")
        itemDetails[idVal] = text
        return text
    }
    
}
