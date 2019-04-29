//
//  CharacterDetailViewController.swift
//  ff14app
//
//  Created by mannyadmin on 4/27/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import UIKit
import CoreData

class CharacterDetailViewController: UITableViewController {
    var characterId: Int = -1 // used to push forward the characterId from main or search
    var characterState: Int = -1 // returned from the initial API call, represents what was found
    var character: FullCharacter = FullCharacter()
    let dispatchGroup = DispatchGroup()
    let sectionHeadings: [String] = ["Character Info", "Job Info"]
    var coreDataCharacter: NSManagedObjectID? = nil // holds the objectID from CoreData
    var managedObjectContext: NSManagedObjectContext! // used to access coredata
    var appDelegate: AppDelegate! // used to access coredata
    @IBOutlet weak var saveDeleteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
        self.character.id = self.characterId
        self.saveDeleteButton.isEnabled = false
        self.findCharacter()
        if self.coreDataCharacter != nil {
            self.saveDeleteButton.title = "Delete"
        }
        self.characterDispatch()
    }
    
    // logic for the save/delete button.  saves or deletes character from CoreData
    @IBAction func saveDeleteCharacter(_ sender: Any) {
        if saveDeleteButton.title == "Save" {
            self.addCharacter()
            self.saveDeleteButton.title = "Delete"
        } else {
            self.removeCharacter(self.coreDataCharacter!)
            self.coreDataCharacter = nil
            self.saveDeleteButton.title = "Save"
        }
    }

    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.characterState == 2 {
            return self.sectionHeadings.count
        } else {
            return 1
        }
    }
    
    // number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.characterState == 2 {
            if section == 0 {
                return 8
            } else if section == 1 {
                return self.character.jobIdArray.count
            } else {
                return 0
            }
        } else {
            return 1
        }
    }
    
    // section titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeadings[section]
    }
    
    // fill cells with stuff
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseCell") as! DetailCell
        if indexPath.section == 0 && self.characterState == 2 {
            cell.rightLabel.text = ""
            switch indexPath.row {
            case 0:
                cell.leftLabel.text = "Name: " + self.character.name
            case 1:
                cell.leftLabel.text = "Title: " + self.character.title
            case 2:
                cell.leftLabel.text = "Server: " + self.character.server
            case 3:
                cell.leftLabel.text = "Race: " + self.character.race
            case 4:
                cell.leftLabel.text = "Gender: " + self.character.gender
            case 5:
                cell.leftLabel.text = "City-State: " + self.character.cityState
            case 6:
                cell.leftLabel.text = "Grand Company: " + self.character.grandCompany
            case 7:
                cell.leftLabel.text = "Rank: " + self.character.rank
            default:
                cell.leftLabel.text = ""
                print("Error: Invalid row found")
            }
        } else if indexPath.section == 1 && self.characterState == 2 {
            cell.leftLabel.text = self.character.jobIdToName[self.character.jobIdArray[indexPath.row]]
            cell.rightLabel.text = String(self.character.jobIdToLevel[self.character.jobIdArray[indexPath.row]]!)
        } else if self.characterState == 1 {
            cell.leftLabel.text = "Adding character to db, try again in 2 minutes"
            cell.rightLabel.text = ""
        } else if self.characterState == -1 {
            cell.leftLabel.text = "Loading, please wait"
            cell.rightLabel.text = ""
        } else {
            cell.leftLabel.text = "Error: Character not found"
            cell.rightLabel.text = ""
        }

        return cell
    }
    
    // gets the character and job names asynchronously
    func characterDispatch() {
        self.dispatchGroup.enter()
        self.getCharacter(self.character.id)
        
        self.dispatchGroup.enter()
        self.getJobs()
        
        self.dispatchGroup.notify(queue: .main) {
            // if the character was found, proceed, otherwise reload w/ message
            if self.characterState == 2 {
                self.everythingElseDispatch()
            } else {
                self.saveDeleteButton.isEnabled = false
                self.tableView.reloadData()
            }
        }
    }
    
    // gets the character's title, city-state, race, and rank asynchronously
    func everythingElseDispatch() {
        self.dispatchGroup.enter()
        self.getTitle(self.character.titleId)
        
        self.dispatchGroup.enter()
        self.getCityState(self.character.cityStateId)
        
        self.dispatchGroup.enter()
        self.getRace(self.character.raceId)
        
        self.dispatchGroup.enter()
        self.getRank(self.character.grandCompanyId, self.character.gender, self.character.rankId)
        
        self.dispatchGroup.notify(queue: .main) {
            self.character.jobIdArray = Array(self.character.jobIdToLevel.keys)
            self.saveDeleteButton.isEnabled = true
            self.tableView.reloadData()
        }
    }
    
    // queries API based on character ID
    func getCharacter(_ characterId: Int) {
        let url = URL(string: "https://xivapi.com/character/" + String(characterId))
        print("https://xivapi.com/character/" + String(characterId))
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleCharacter)
        dataTask.resume()
    }
    
    // queries API based on job ID
    func getJobs() {
        let url = URL(string: "https://xivapi.com/ClassJob")
        print("https://xivapi.com/ClassJob")
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleJobs)
        dataTask.resume()
    }
    
    // queries API based on title ID
    func getTitle(_ titleId: Int) {
        let url = URL(string: "https://xivapi.com/Title?ids=" + String(titleId))
        print("https://xivapi.com/Title?ids=" + String(titleId))
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleTitle)
        dataTask.resume()
    }
    
    // queries API based on city-state ID
    func getCityState(_ cityStateId: Int) {
        let url = URL(string: "https://xivapi.com/Town?ids=" + String(cityStateId))
        print("https://xivapi.com/Town?ids=" + String(cityStateId))
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleCityState)
        dataTask.resume()
    }
    
    // queries API based on race ID
    func getRace(_ raceId: Int) {
        let url = URL(string: "https://xivapi.com/Race?ids=" + String(raceId))
        print("https://xivapi.com/Race?ids=" + String(raceId))
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleRace)
        dataTask.resume()
    }
    
    // queries API based on rank ID (different urls based on gender and grand company)
    func getRank(_ gcId: Int, _ gender: String, _ rankId: Int) {
        var url: URL
        if gender == "Male" {
            if gcId == 1 { // Maelstrom
                url = URL(string: "https://xivapi.com/GCRankLimsaMaleText?ids=" + String(rankId))!
                print("https://xivapi.com/GCRankLimsaMaleText?ids=" + String(rankId))
            } else if gcId == 2 { // Twin Adder
                url = URL(string: "https://xivapi.com/GCRankGridaniaMaleText?ids=" + String(rankId))!
                print("https://xivapi.com/GCRankGridaniaMaleText?ids=" + String(rankId))
            } else { // Immortal Flames
                url = URL(string: "https://xivapi.com/GCRankUldahMaleText?ids=" + String(rankId))!
                print("https://xivapi.com/GCRankUldahMaleText?ids=" + String(rankId))
            }
        } else {
            if gcId == 1 { // Maelstrom
                url = URL(string: "https://xivapi.com/GCRankLimsaFemaleText?ids=" + String(rankId))!
                print("https://xivapi.com/GCRankLimsaFemaleText?ids=" + String(rankId))
            } else if gcId == 2 { // Twin Adder
                url = URL(string: "https://xivapi.com/GCRankGridaniaFemaleText?ids=" + String(rankId))!
                print("https://xivapi.com/GCRankGridaniaFemaleText?ids=" + String(rankId))
            } else { // Immortal Flames
                url = URL(string: "https://xivapi.com/GCRankUldahFemaleText?ids=" + String(rankId))!
                print("https://xivapi.com/GCRankUldahFemaleText?ids=" + String(rankId))
            }
        }
        let dataTask = URLSession.shared.dataTask(with: url, completionHandler: handleRank)
        dataTask.resume()
    }
    
    // handles API JSON response based on character ID
    func handleCharacter (data: Data?, response: URLResponse?, error: Error?) {
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
                    print("resolving character handler")
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        let infoDict = jsonObj["Info"] as? [String: Any]
                        let infoCharDict = infoDict!["Character"] as? [String: Any]
                        self.characterState = infoCharDict!["State"] as! Int
                        
                        // if the character was found and returned
                        if self.characterState == 2 {
                            let characterDict = jsonObj["Character"] as? [String: Any]
                            if characterDict!["Gender"] as! Int == 2 {
                                self.character.gender = "Female"
                            } else {
                                self.character.gender = "Male"
                            }
                            self.character.name = characterDict!["Name"] as! String
                            self.character.server = characterDict!["Server"] as! String
                            self.character.cityStateId = characterDict!["Town"] as! Int
                            self.character.raceId = characterDict!["Race"] as! Int
                            self.character.titleId = characterDict!["Title"] as! Int
                            
                            let gcDict = characterDict!["GrandCompany"] as! [String: Int]
                            self.character.grandCompanyId = gcDict["NameID"]!
                            self.character.rankId = gcDict["RankID"]!
                            
                            if self.character.grandCompanyId == 1 {
                                self.character.grandCompany = "Maelstrom"
                            } else if self.character.grandCompanyId == 2 {
                                self.character.grandCompany = "Order of the Twin Adder"
                            } else {
                                self.character.grandCompany = "Immortal Flames"
                            }
                            
                            let jobDict = characterDict!["ClassJobs"] as! [String: [String: Any]]
                            
                            for (_, value) in jobDict {
                                self.character.jobIdToLevel[value["JobID"] as! Int] = value["Level"] as? Int
                            }
                        }
                    } else {
                        print("error: invalid JSON data initial [String: Any] cast in character handler")
                    }
                    self.dispatchGroup.leave()
                }
            }
        }
    }
    
    // handles API JSON response of all jobs
    func handleJobs (data: Data?, response: URLResponse?, error: Error?) {
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
                    print("resolving jobs handler")
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        let jobArray = jsonObj["Results"] as! Array<[String: Any]>
                        for jobDict in jobArray {
                            self.character.jobIdToName[jobDict["ID"] as! Int] = jobDict["Name"] as? String
                        }
                    } else {
                        print("error: invalid JSON data initial [String: Any] cast in job handler")
                    }
                    self.dispatchGroup.leave()
                }
            }
        }
    }
    
    // handles API JSON response based on title ID
    func handleTitle (data: Data?, response: URLResponse?, error: Error?) {
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
                    print("resolving title handler")
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        let titleArray = jsonObj["Results"] as! Array<[String: Any]>
                        for titleDict in titleArray {
                            self.character.title = titleDict["Name"] as! String
                        }
                    } else {
                        print("error: invalid JSON data initial [String: Any] cast in title handler")
                    }
                    self.dispatchGroup.leave()
                }
            }
        }
    }
    
    // handles API JSON response based on city-state ID
    func handleCityState (data: Data?, response: URLResponse?, error: Error?) {
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
                    print("resolving city-state handler")
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        let cityStateArray = jsonObj["Results"] as! Array<[String: Any]>
                        for cityStateDict in cityStateArray {
                            self.character.cityState = cityStateDict["Name"] as! String
                        }
                    } else {
                        print("error: invalid JSON data initial [String: Any] cast in city-state handler")
                    }
                    self.dispatchGroup.leave()
                }
            }
        }
    }
    
    // handles API JSON response based on race ID
    func handleRace (data: Data?, response: URLResponse?, error: Error?) {
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
                    print("resolving race handler")
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        let raceArray = jsonObj["Results"] as! Array<[String: Any]>
                        for raceDict in raceArray {
                            self.character.race = raceDict["Name"] as! String
                        }
                    } else {
                        print("error: invalid JSON data initial [String: Any] cast in race handler")
                    }
                    self.dispatchGroup.leave()
                }
            }
        }
    }
    
    // handles API JSON response based on rank ID
    func handleRank (data: Data?, response: URLResponse?, error: Error?) {
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
                    print("resolving rank handler")
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) as? [String: Any] {
                        let rankArray = jsonObj["Results"] as! Array<[String: Any]>
                        for rankDict in rankArray {
                            self.character.rank = rankDict["Name"] as! String
                        }
                    } else {
                        print("error: invalid JSON data initial [String: Any] cast in rank handler")
                    }
                    self.dispatchGroup.leave()
                }
            }
        }
    }
    
    // adds a character to the DataStore
    func addCharacter() {
        print("adding character")
        let character = NSEntityDescription.insertNewObject(forEntityName: "CharacterEntity", into: self.managedObjectContext)
        character.setValue(self.character.name, forKey: "name")
        character.setValue(self.character.id, forKey: "id")
        character.setValue(self.character.server, forKey: "server")

        self.appDelegate.saveContext() // In AppDelegate.swift
        self.coreDataCharacter = character.objectID
    }
    
    // checks if a character with current characterID is in the coredata
    // if so, assigns the objectid of that character to self.coreDataCharacter
    func findCharacter() {
        print("finding character")
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CharacterEntity")
        fetchRequest.predicate = NSPredicate(format: "id == \(self.character.id)")
        var characters: [NSManagedObject]!
        do {
            characters = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("getCharacters error: \(error)")
        }
        if characters.count > 0 {
            for character in characters {
                self.coreDataCharacter = character.objectID
            }
        }
    }
    
    // removes a question from the DataStore
    func removeCharacter(_ characterId: NSManagedObjectID) {
        print("removing character")
        let character: NSManagedObject = self.managedObjectContext.object(with: characterId)
        self.managedObjectContext.delete(character)
        
        self.appDelegate.saveContext() // In AppDelegate.swift
    }
}
