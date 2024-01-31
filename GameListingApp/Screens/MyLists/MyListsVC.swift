//
//  ProfileVC.swift
//  GameListingApp
//
//  Created by Yiğithan Sönmez on 31.12.2023.
//

import UIKit

protocol MyListsVCProtocol: AnyObject {
    func reloadTableView()
    func navigateToView(vc: ListDetailsVC)
    func presentCreateListView(vc: CreateListVC)
}

final class MyListsVC: UIViewController {
    // MARK: - Properties
    private lazy var viewModel: MyListsVMProtocol = MyListsVM()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MyListsTableViewCell.self, forCellReuseIdentifier: MyListsTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        
        prepareView()
    }
    
    // TODO: Optimize (add refresh functionality)
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchLists()
    }
    
    func prepareView() {
        view.backgroundColor = .systemBackground
        title = "My Lists"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        let addListNavItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addListButtonTapped))
        navigationItem.rightBarButtonItem = addListNavItem
        
        applyConstraints()
    }
    
    @objc func addListButtonTapped() {
        viewModel.addListButtonTapped()
    }
    
    // MARK: - Constraints
    
    private func applyConstraints(){
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - TableView

extension MyListsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getListsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyListsTableViewCell.identifier, for: indexPath) as? MyListsTableViewCell else { return UITableViewCell() }
        
        let listName = viewModel.getListName(by: indexPath.row)
        let gameCount = viewModel.getNumberOfGamesInList(by: indexPath.row)
        
        cell.selectionStyle = .none
        cell.configure(listName: listName, gameCount: String(gameCount))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRow(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            if viewModel.deleteList(at: indexPath.row) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            tableView.endUpdates()
        }
    }
    
}

// MARK: - MyListsVCProtocol

extension MyListsVC: MyListsVCProtocol {
    func presentCreateListView(vc: CreateListVC) {
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func navigateToView(vc: ListDetailsVC) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
