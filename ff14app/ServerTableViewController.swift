//
//  ServerTableViewController.swift
//  ff14app
//
//  Created by mannyadmin on 3/30/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import UIKit

class ServerTableViewController: UITableViewController {
    var serverDict: [String: Server] = [:]
    var realmArray: [Realm] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getServers()
    }

    // number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return realmArray.count
    }
    
    // number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realmArray[section].servers.count
    }
    
    // section titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.realmArray[section].realmName
    }
    
    // puts stuff in the cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serverCell") as! ServerCell
        cell.leftLabel.text = realmArray[indexPath.section].servers[indexPath.row].serverName
        cell.rightLabel.text = realmArray[indexPath.section].servers[indexPath.row].status

        return cell
    }
    
    // calls the API for server status
    func getServers() {
        let url = URL(string: "https://xivapi.com/lodestone/worldstatus")
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleServerResponse)
        dataTask.resume()
    }
    
    // handles the json response from the API call for server status
    // calls getRealms after parsing the data
    func handleServerResponse (data: Data?, response: URLResponse?, error: Error?) {
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
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) {
                        let serverArray = jsonObj as! Array<[String: String]>
                        for jsonServerDict in serverArray {
                            self.serverDict[jsonServerDict["Title"]!] = Server(serverName: jsonServerDict["Title"]!, status: jsonServerDict["Status"]!)
                        }
                        self.getRealms()
                    } else {
                        print("error: invalid JSON data")
                    }
                }
            }
        }
    }
    
    // calls the API for realms and their associated servers
    func getRealms() {
        let url = URL(string: "https://xivapi.com/servers/dc")
        let dataTask = URLSession.shared.dataTask(with: url!, completionHandler: handleRealmResponse)
        dataTask.resume()
    }
    
    // handles the json response from the API call for realms and their associated servers
    func handleRealmResponse (data: Data?, response: URLResponse?, error: Error?) {
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
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data!) {
                        let jsonDict = jsonObj as! [String: Array<String>]
                        for (realm, serverArray) in jsonDict {
                            let tempRealm = Realm(realmName: realm)
                            for server in serverArray {
                                tempRealm.servers.append(self.serverDict[server]!)
                            }
                            self.realmArray.append(tempRealm)
                        }
                        self.realmArray.sort() { $0.realmName < $1.realmName }
                        self.tableView.reloadData()
                    } else {
                        print("error: invalid JSON data")
                    }
                }
            }
        }
    }
}
