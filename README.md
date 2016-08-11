
## **BookHub**

**Part 1**
-  Start this project by creating a new branch off of **Starting Point V2**

- This project has a base starting point where all the views and constraints have been setup for you so you can spend your time researching and coding.

-	Your goal is to create a library collection of books using a collection view and cloudKit sorted by date added.

- If you know how to use a **Table View** than you know how to use a **Collection View**. Read up on documentation & online resources about **Collection Views** to see the additional cool things they can do.

- The first view (BookListViewController) will display the book cover image of your saved book as well as the rating you gave the book. This BookListCollectionView's items (known as rows in a Table View) will be updated automatically by fetching the most recent collection off of CloudKit.

![booklistview](https://cloud.githubusercontent.com/assets/6709516/17558897/6b08e464-5ed9-11e6-93ad-40f04e280b4f.png)

- In the AddBookViewController you have a button called **Get Book Cover**, use this button's action to open up a safari webpage that takes you directly to a book cover website to download the latest book cover images. A website url has been provided to you in code to grab the images from.
 
![bookdetailview](https://cloud.githubusercontent.com/assets/6709516/17558899/6d04c418-5ed9-11e6-9a0d-fdc6b88e668d.png)

- In the AddBookViewController update the imageView with the book cover, give your book a rating and save it to CloudKit.

-	Use the following code as your starting point for your CloudKitManager:
	
    import UIKit
    import CloudKit
    
    class CloudKitManager {
        
        let database = CKContainer.defaultContainer().publicCloudDatabase
        
        func fetchRecordsWithType(type: String, sortDescriptors: [NSSortDescriptor]? = nil, completion: ([CKRecord]?, NSError?) -> Void) {
            
            let query = CKQuery(recordType: type, predicate: NSPredicate(value: true))
            query.sortDescriptors = sortDescriptors
            
            database.performQuery(query, inZoneWithID: nil, completionHandler: completion)
        }
        
        func saveRecord(record: CKRecord, completion: ((NSError?) -> Void) = {_ in }) {
    
            database.saveRecord(record) { (_, error) in
                completion(error)
            }
        }
    }

**Part 2**

- In **Part 1** you should have created your project using the standard methods learned in the **Bulletin Board** project. For this project we're going to update our code to be more in line with **Timeline** and get better acquainted with the code being used there.
- Start off by creating a new folder called **Protocols** and inside of there create a Swift file called **CloudKitSyncable**. The purpose of this file should be obvious considering that it's in a folder called **Protocols** and Protocols are essentially contracts to fulfill for whoever conforms to them.
	- For additional information on protocols and delegates read the following excellent article by Andrew Bancroft. 
	- https://www.andrewcbancroft.com/2015/04/08/how-delegation-works-a-swift-developer-guide/

- We know that for every model that we want to be able to save to CloudKit it needs to at least conform and have the following properties. Fill out CloudKitSyncable with the info below. 
	- A **failable initializer** with a parameter of **CKRecord**
	- A **var recordType String** that is only **get** ' able (remember this is usually the name of your model that you're going to store in CloudKit)
	- And a **var cloudKitRecordID** of type **CKRecordID?** (Note that this is essentially a NSUUID but for CKRecords)

- Still in the same file create an extension of CloudKitSyncable and implement the following computed variables. Note how broadly they're written so that they can be used on any model that conforms to this protocol.
	- A **var isSynced of type Bool** computed property. That **returns** a **cloudKitRecordID** that is not **nil**
	- A **var cloudKitReference of type CKReference?** computed property. That checks if a **cloudKitRecordID** exists or **returns nil**. Do this with a **guard** statement and name your **constant recordID**.
		- Finally **return** a **CKReference initialized** with the **recordID** and pass **.None** for the action. 

- We want our model to be able to conform to the **Syncable Protocol** but if your model is a **Struct** which is value based it cannot inherit the protocol. Come **Class** to the rescue which allows for **inheritance**. 
	- Update your model to a **Class**
	- Being a **Class** you will need to implement the required memberwise initializer.
	- If you had a Model+CloudKit file know that we will be getting rid of it. You may want to keep it around while you build your Class for reference.
	- Conform to **Syncable Protocol** and implement the required properties
		- Note that when you implement your failable init from the protocol that you will need to add the **convenience** syntax + **required** before the **init?**
		- Read the following StackOverflow question and first response for an excellent description of **convenience init's**
		- http://stackoverflow.com/questions/30896231/why-convenience-keyword-is-even-needed-in-swift
		- Failable init breakdown continues after side note below

- One of the major purposes of Part 2 of this project is to get us away from saving images as Bytes/NSData in CloudKit and use CKAsset instead as that is the correct type to save large files to in CloudKit.
	![screenshot 2016-08-11 09 51 20](https://cloud.githubusercontent.com/assets/6709516/17598383/6e3e4cd0-5fb7-11e6-97ee-b41d2f919d79.png)

- A record can only be 1MB large so eventually if we keep on using NSData to store an image or some large file we'll run into an issue where it won't allow us to save our record due to exceeding the 1MB limit
	- Note that NSData provides a wrapper around your CKRecord and could be used as a way to encrypt your information in CloudKit.

**Back to the Failable Init**

- when we retrieve our photo using something along the lines of **record[Model.photoDataKey]** you want to cast the result as a **CKAsset** instead of **NSData** .
	- wrap up your guard statement and create a **constant** called **photoData** that has a value of **NSData** and is **initialized** by the **contentsofURL**. The contents of url to pass into here is your constant in the guard statement cast as the CKAsset. You'll notice that this alone won't work as it's asking for an NSURL.
		- open documentation and look up CKAsset for a property that will return you an NSURL.
- call **self.init** and initialize the class with all your properties  
- Finally call **cloudKitRecordID** and set it to equal the **record** of your failable init (which is a **CKRecord**) and call the **recordID** parameter on it. We should now be done with our failable initializer.

------
- CKAssets take some additional work to convert to an image in your app since they do use NSData to create an Image

 - Add the following computed property below which will create a temporary directory to pass the image file path url to the CKAsset.

  

  private var temporaryPhotoURL: NSURL {
          
             let temporaryDirectory = NSTemporaryDirectory()
            let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
            let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString).URLByAppendingPathExtension("jpg")
            
            photoData?.writeToURL(fileURL, atomically: true)
            
            return fileURL
        }


- Create an extension on CKRecord
	- This extension will convert our model to a **CKRecord**
	- Create a **convenience** **initializer** that takes a parameter of your **model**
		- Note that if you wish not to have the name of the parameter to show up when you call this init you can silence/ignore it with an underscore.
		- create a **constant** called recordID that equals an **initialized CKRecordID** that takes a **recordName**. That record name will be an initialized **NSUUID** that is converted to a **string**. 
		- **Hint** Look up NSUUID for a parameter that converts your NSUUID to a string.
		- call **init** on the CKRecord **itself** and initialize with a **recordType** and the **recordID**
		- Finally since a CKRecord is essentially a glorified dictionary call **self** and then the **key** for your parameters and have them equal the **value** of the appropriate **model property** that we're going to store to CloudKit. 
			- **Hint** There should be there properties you're storing 

	
	- Head over to your CloudKitManager and update your saveRecord func to the code below.
	 

    func saveRecord(record: CKRecord, completion: ((record: CKRecord?, error: NSError?) -> Void)?) {
            
            database.saveRecord(record) { (record, error) in
                
                completion?(record: record, error: error)
            }
        }
        
- This should get you far enough to complete Part 2 of this project. You **will** have errors in other files due to updating your Model and CloudKitManager.  Update your model controller and the rest of your code to take advantage of the upgrades you've made.  You're project on the surface should essentially work as before when you completed Part 1.

- One last note.... since the information you're storing in CloudKit has changed you will need to go to your CloudKit Dashboard and delete your original **Record Type** and all the records saved in the **public Default Zone.**

- Note that this project is completely CloudKit based/network dependent and does not use local persistence to save your data, all data will be saved to the cloud and should automatically populate your collection view upon loading your app every time.
