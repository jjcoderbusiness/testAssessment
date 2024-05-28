//
//  ViewController.swift
//  Task
//
//  Created by Jagdish Jangir on 28/05/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = ListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        fetchData()
        
    }
    
    func fetchData() {
        
        Task {
            do {
                var lastRowIndex = self.viewModel.data.count
                let newItemsCount = try await viewModel.fetchNextPageData()
                var newItemsIndexPaths: [IndexPath] = []
                for _ in 0..<newItemsCount {
                    newItemsIndexPaths.append(IndexPath(row: lastRowIndex, section: 0))
                    lastRowIndex += 1
                }
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.performBatchUpdates {
                        self?.tableView.insertRows(at: newItemsIndexPaths, with: .automatic)
                    }
                }
            }catch {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title:"Error", message: error.localizedDescription, preferredStyle: .alert)
                    self?.show(alert, sender: nil)
                }
            }
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let item = self.viewModel.data[indexPath.row]
        cell.textLabel?.text = "ID-\(item.id ?? 0)"
        cell.detailTextLabel?.text = item.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
        let start = Date().timeIntervalSince1970
        detailVC.text = self.viewModel.selectedItemDetails(self.viewModel.data[indexPath.row])
        let end = Date().timeIntervalSince1970
        print("Computation time \(end - start), ItemRow \(indexPath.row)")
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let rem = UInt(indexPath.row + 1) % self.viewModel.limit
        let exp = UInt(indexPath.row + 1) / self.viewModel.limit
        
        let shouldReload = (rem == 0) && (exp >= viewModel.currentPage)
        
        if shouldReload { // Fetch New Data only in downward direction
            print("API CALLED")
            fetchData()
        }
    }
}
