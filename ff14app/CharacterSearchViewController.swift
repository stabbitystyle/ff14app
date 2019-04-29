//
//  CharacterSearchViewController.swift
//  ff14app
//
//  Created by mannyadmin on 3/31/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import UIKit

class CharacterSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var characterSearchBar: UISearchBar!
    @IBOutlet weak var searchResultsTable: UITableView!
    
    var characterArray: [Character] = []
    var selectedId: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchResultsTable.delegate = self
        self.searchResultsTable.dataSource = self
        self.characterSearchBar.delegate = self
    }
    
    // if the search button is clicked, clear current results, search for character, close keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text != nil) {
            self.characterArray.removeAll()
            self.getCharacterSearchResults(self.formatText(searchBar.text!))
            self.characterSearchBar.endEditing(true)
        }
    }
    
    // number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characterArray.count
    }
    
    // section titles
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Results"
    }
    
    // populates cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell") as! CharacterCell
        cell.characterName.text = self.characterArray[indexPath.row].name
        cell.characterServer.text = self.characterArray[indexPath.row].server
        
        return cell
    }
    
    // trims whitespace and replaces spaces with + for API usage
    func formatText(_ inputString: String) -> String {
        let trimmedString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString.replacingOccurrences(of: " ", with: "+")
    }
    
    // queries the API for a character
    func getCharacterSearchResults(_ characterSearchString: String) {
        let url = URL(string: "https://xivapi.com/character/search?name=" + characterSearchString)
        print("https://xivapi.com/character/search?name=" + characterSearchString)
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleSearchResponse)
        dataTask.resume()
    }
    
    // parses the json results from the API
    func handleSearchResponse (data: Data?, response: URLResponse?, error: Error?) {
        if let err = error {
            print("error: \(err.localizedDescription)")
        } else {
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            if statusCode != 200 {
                let msg = HTTPURLResponse.localizedString(forStatusCode: statusCode)
                print("HTTP \(statusCode) error: \(msg)")
            } else {
                // response okay, do something with data
                DispatchQueue.main.async {
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        if let resultArray = jsonObj["Results"] as? Array<[String: Any]> {
                            if resultArray.isEmpty {
                                self.characterArray.append(Character(name: "No results found", id: -1, server: ""))
                            } else {
                                for characterDict in resultArray {
                                    self.characterArray.append(Character(name: characterDict["Name"]! as! String, id: characterDict["ID"]! as! Int, server: characterDict["Server"]! as! String))
                                }
                            }
                        } else {
                            print("error: invalid JSON data second Array<[String: Any]> cast")
                        }
                    } else {
                        print("error: invalid JSON data initial [String: Any] cast")
                    }
                    // updates table with results
                    self.searchResultsTable.reloadData()
                }
            }
        }
    }
    
    // when one of the rows are selected, takes the user to the character detail screen
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedId = self.characterArray[indexPath.row].id
        performSegue(withIdentifier: "segueToCharacterDetail", sender: nil)
    }
    
    // passes the characterID forward to the character detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCharacterDetail" {
            let cdViewController = segue.destination as! CharacterDetailViewController
            cdViewController.characterId = self.selectedId
        }
    }
    
    // unwinds from character detail view
    @IBAction func unwindFromDetail (segue: UIStoryboardSegue) {
        print("unwinding in search")
    }
}
