//
//  ViewController.swift
//  Project7
//
//  Created by Marcus Falck on 01/10/22.
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    var filterPetitions = [Petition]()
    var selectedTab: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(showApiCredit))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearchAC))
        
        selectedTab = navigationController?.tabBarItem.tag ?? 0
        performSelector(inBackground: #selector(fetchJson), with: nil)
        
    }
    
    @objc func fetchJson(){
        let urlString : String
        if selectedTab == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        }
        else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        let url = URL(string: urlString)!
        if let data = try? Data(contentsOf: url) {
            self.parse(json: data)
            return
        }
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    @objc func showApiCredit(_: UIAlertAction) {
        let ac = UIAlertController(title: "Credit", message: "This data is provided by 'We the People' Api of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: .none))
        present(ac, animated: true, completion: .none)
    }
    
    @objc func showSearchAC() {
        let ac = UIAlertController(title: "Enter text to search", message: .none, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        
        let action = UIAlertAction(title: "Find", style: .default) { [weak self, weak ac] _ in
            
            guard let text = ac?.textFields?[0].text else { return }
            
            self?.performSelector(inBackground: #selector(self?.configurePetitions(for:)), with: text)
            self?.tableView?.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }
        ac.addAction(action)
        present(ac, animated: true, completion: .none)
    }
    
    @objc func configurePetitions(for filterWord: String){
        filterPetitions.removeAll()
        
        if filterWord.isEmpty {
            filterPetitions = petitions
        }
        else
        {
            for petition in petitions {
              if petition.title.lowercased().contains(filterWord.lowercased()) {
                filterPetitions.append(petition)
              }
            }
        }
    }
    
    
    func parse (json: Data){
        let decoder = JSONDecoder()
        if let jsonPetitions = try?  decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filterPetitions = petitions
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        }
        else{
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filterPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petition = filterPetitions[indexPath.row]
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = petition.title
        contentConfig.secondaryText = petition.body
        cell.contentConfiguration = contentConfig
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filterPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func showError(){
            DispatchQueue.main.async {
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem in loading a feed. Please check your connnection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(ac, animated: true, completion: nil)
        }
    }


}

