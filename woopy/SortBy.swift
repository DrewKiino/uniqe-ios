/*-----------------------------------
 
 - UNQ -
 
 created by Christian Noble © 2017
 All Rights reserved to UNQ
 
 -----------------------------------*/


import UIKit



class SortBy: UIViewController,
UITableViewDelegate,
UITableViewDataSource
{

    
    /* Views */
    @IBOutlet weak var sortTableView: UITableView!
    
    
    
    /* Variables */
    var sortByArr = ["Recent",
                     "Lowest Price",
                     "Highest Price",
                     "New",
                     "Used",
                     "Most Liked",
                    ]
    
    var selectedSort = ""
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()


}

   
 
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sortByArr.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
    cell.textLabel?.text = "\(sortByArr[indexPath.row])"
        
        
return cell
}
    
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
}
    
    
// MARK: - CELL TAPPED
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedSort = "\(sortByArr[indexPath.row])"
}
    
    
    
    
    
// MARK: - DONE BUTTON
@IBAction func doneButt(_ sender: Any) {
    if selectedSort != "" {
        sortBy = selectedSort
        dismiss(animated: true, completion: nil)
    } else {
        simpleAlert("You must select an option!")
    }
}
    
    
    
    
    
    
// MARK: - CANCEL BUTTON
@IBAction func cancelButt(_ sender: Any) {
    dismiss(animated: true, completion: nil)
}
    
    

    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
