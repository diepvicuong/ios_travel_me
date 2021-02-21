//
//  SearchUserVC.swift
//  travelme
//
//  Created by DiepViCuong on 2/21/21.
//

import UIKit

class SearchUserVC: AbstractViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var users = [User]()
    private var filteredUsers = [User]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var isSearchBarEmpty: Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool{
        return searchController.isActive && !isSearchBarEmpty
    }
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter username"
        sb.autocorrectionType = .no
        sb.autocapitalizationType = .none
        sb.barTintColor = .gray
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initLayout()
        initSearchController()
    }
    
    private func initLayout(){

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserSearchCell.self, forCellReuseIdentifier: UserSearchCell.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl
        
        searchBar.delegate = self
        
        fetchAllUsers()
    }
    
    private func initSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    @objc private func handleRefresh() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        tableView?.refreshControl?.beginRefreshing()
        
        UserRepository.sharedInstance.fetchAllUser(includeCurrentUser: false, completion: { (users) in
            let sortedUser = users.sorted{ $0.username.lowercased() < $1.username.lowercased()}
            self.users = sortedUser
            self.filteredUsers = sortedUser
            
            self.searchBar.text = ""
            self.tableView?.reloadData()
            self.tableView?.refreshControl?.endRefreshing()
        }) { (_) in
            self.tableView?.refreshControl?.endRefreshing()
        }
    }
}

//MARK: -
extension SearchUserVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering{
            return self.filteredUsers.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserSearchCell.cellId, for: indexPath) as! UserSearchCell
        if isFiltering{
            cell.user = filteredUsers[indexPath.row]
        }else{
            cell.user = users[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser: User
        if isFiltering{
            selectedUser = filteredUsers[indexPath.row]
        }else{
            selectedUser = users[indexPath.row]
        }
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.user = selectedUser
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

//MARK: - UISearchBarDelegate
extension SearchUserVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //
    }
}

//MARK: - UISearchResultsUpdating
extension SearchUserVC: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String, category: String? = nil){
        filteredUsers = users.filter{ (user: User) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}
