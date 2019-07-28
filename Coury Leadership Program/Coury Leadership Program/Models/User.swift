//
//  User.swift
//  Coury Leadership Program
//
//  Created by Hayden Shively on 2/8/19.
//  Copyright © 2019 USC Marshall School of Business. All rights reserved.
//

import Foundation
import Firebase
import GoogleSignIn

public class CLPUser {

    public var isSigningIn: Bool = false
    private var isBulkUpdating: Bool = false

    public private(set) var name: String? {
        didSet {if name != nil && !isBulkUpdating {Database.shared.updateUserProfile(self)}}
    }
    public private(set) var id: String? {
        didSet {if id != nil && !isBulkUpdating {Database.shared.updateUserProfile(self)}}
    }
    public private(set) var values: [String]? {
        didSet {
            if values != nil && !isBulkUpdating {Database.shared.updateUserProfile(self)}
            if (values != nil) && (!(oldValue?.elementsEqual(values!) ?? false)) {
                for value in values! {
                    Messaging.messaging().subscribe(toTopic: value) { error in
                        print("Subscribed to \(value) notification topic")
                    }
                }
            }
        }
    }
    public private(set) var strengths: [String]? {
        didSet {
            if strengths != nil && !isBulkUpdating {Database.shared.updateUserProfile(self)}
            if (strengths != nil) && (!(oldValue?.elementsEqual(strengths!) ?? false)) {
                for strength in strengths! {
                    Messaging.messaging().subscribe(toTopic: strength) { error in
                        print("Subscribed to \(strength) notification topic")
                    }
                }
            }
        }
    }
    public private(set) var savedContent: [Int]? {
        didSet {if savedContent != nil && !isBulkUpdating {Database.shared.updateUserProfile(self)}}
    }
    public private(set) var answeredPolls: [Int]? {
        didSet {if answeredPolls != nil && !isBulkUpdating {Database.shared.updateUserProfile(self)}}
    }

    private static var sharedUser: CLPUser = {return CLPUser()}()
    private init() {
        if let googleUser = Auth.auth().currentUser {
            name = googleUser.displayName
            id = googleUser.uid
        }
    }
    public static func shared() -> CLPUser {return sharedUser}

    public func reconstruct(name: String?, id: String?, values: [String]?, strengths: [String]?, savedContent: [Int]?, answeredPolls: [Int]?, fromDatabase: Bool = false) {
        isBulkUpdating = true
        self.name = name
        self.id = id
        self.values = values
        self.strengths = strengths
        self.savedContent = savedContent
        self.answeredPolls = answeredPolls
        isBulkUpdating = false
        if !fromDatabase {Database.shared.updateUserProfile(self)}
    }

    public func updateInformation(from googleUser: User) {
        self.name = googleUser.displayName
        self.id = googleUser.uid
    }

    public func makeAllNil() {
        self.name = nil
        self.id = nil
        self.values = nil
        self.strengths = nil
        self.savedContent = nil
        self.answeredPolls = nil
    }

    public func set(values: [String]) {self.values = values}
    public func set(strengths: [String]) {self.strengths = strengths}

    public func toggleSavedContent(for index: Int) {
        if savedContent == nil {
            savedContent = [index]
        }else if let existingLocation = savedContent!.firstIndex(of: index) {
            savedContent!.remove(at: existingLocation)
        }else {
            savedContent!.append(index)
        }
//        else {
//            let existingLocationOfIndexInArray = savedContent!.firstIndex(of: index)
//            if existingLocationOfIndexInArray != nil {savedContent!.remove(at: existingLocationOfIndexInArray!)}
//            else {
//                savedContent!.append(index)
//            }
//        }
    }

    public func addToAnsweredPolls(poll number: Int) {
        if answeredPolls == nil {answeredPolls = [number]}
        else if answeredPolls!.firstIndex(of: number) == nil {
            answeredPolls?.append(number)
        }
    }

    public func toDict() -> [String : String] {
        var dict: [String : String] = [:]

        dict["name"] = name != nil ? name : ""
        dict["id"] = id != nil ? id : ""
        dict["values"] = values != nil ? values!.joined(separator: ",") : ""
        dict["strengths"] = strengths != nil ? strengths!.joined(separator: ",") : ""
        dict["saved content"] = savedContent != nil ? savedContent!.map({String($0)}).joined(separator: ",") : ""
        dict["answered polls"] = answeredPolls != nil ? answeredPolls!.map({String($0)}).joined(separator: ",") : ""
        
        return dict
    }

    public func listOfFullFields() -> [String] {
        var fullFields: [String] = []

        if name != nil {fullFields.append("name")}
        if id != nil {fullFields.append("id")}
        if values != nil {fullFields.append("values")}
        if strengths != nil {fullFields.append("strengths")}
        if savedContent != nil {fullFields.append("saved content")}
        if answeredPolls != nil {fullFields.append("answered polls")}

        return fullFields
    }
}
