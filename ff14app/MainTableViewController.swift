//
//  MainTableViewController.swift
//  ff14app
//
//  Created by mannyadmin on 3/29/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    var appDelegate: AppDelegate!
    var savedCharacters: Array<Character> = []
    var selectedCharacterId: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.managedObjectContext = appDelegate.persistentContainer.viewContext
        self.getCharacters()
        self.tableView.reloadData()
    }

    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.savedCharacters.isEmpty {
            return 1
        } else {
            return 2
        }
        
    }
    
    // number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return self.savedCharacters.count
        }
    }
    
    // section titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Main utilities"
        } else if section == 1 {
            return "Saved characters"
        } else {
            return "Error: Unexpected section"
        }
    }
    
    // fills cells in table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell") as! MainCell
        if indexPath.section == 0 && indexPath.row == 0 {
            cell.leftLabel.text = "Server Status"
            cell.rightLabel.text = ""
        } else if indexPath.section == 0 && indexPath.row == 1 {
            cell.leftLabel.text = "Character Search"
            cell.rightLabel.text = ""
        } else if indexPath.section == 1 {
            cell.leftLabel.text = self.savedCharacters[indexPath.row].name
            cell.rightLabel.text = self.savedCharacters[indexPath.row].server
        } else {
            cell.leftLabel.text = ""
            cell.rightLabel.text = ""
        }
        return cell
    }
    
    // when one of the device settings rows are selected, takes the user to the device settings screen
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "segueToServerStatus", sender: nil)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            performSegue(withIdentifier: "segueToCharacterSearch", sender: nil)
        } else if indexPath.section == 1 {
            self.selectedCharacterId = self.savedCharacters[indexPath.row].id
            performSegue(withIdentifier: "segueToCharacterDetail", sender: nil)
        }
    }
    
    // pushes the character ID forward if going to the character detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToCharacterDetail"
        {
            let cdViewController = segue.destination as! CharacterDetailViewController
            cdViewController.characterId = self.selectedCharacterId
        }
    }
    
    // unwinding from the Character Detail view
    @IBAction func unwindFromDetail (segue: UIStoryboardSegue) {
        print("unwinding in main from detail")
        self.savedCharacters.removeAll()
        self.getCharacters()
        self.tableView.reloadData()
    }
    
    // unwinding from the Character Search view
    @IBAction func unwindFromSearch (segue: UIStoryboardSegue) {
        print("unwinding in main from search")
        self.savedCharacters.removeAll()
        self.getCharacters()
        self.tableView.reloadData()
    }
    
    // gets questions from the DataStore and puts them in the local questions array
    func getCharacters() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CharacterEntity")
        var characters: [NSManagedObject]!
        do {
            characters = try self.managedObjectContext.fetch(fetchRequest)
        } catch {
            print("getCharacters error: \(error)")
        }
        print("Found \(characters.count) characters")
        for character in characters {
            let newCharacter = Character(name: character.value(forKey: "name") as! String,
                                         id: character.value(forKey: "id") as! Int,
                                         server: character.value(forKey: "server") as! String)
            
            self.savedCharacters.append(newCharacter)
        }
    }
}
    

    


