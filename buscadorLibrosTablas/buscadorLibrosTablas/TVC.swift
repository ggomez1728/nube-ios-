//
//  TVC.swift
//  buscadorLibrosTablas
//
//  Created by Pollinion User on 29/02/16.
//  Copyright © 2016 Pollinion INC. All rights reserved.
//

import UIKit

import CoreData

struct BookSearch {
    var isbn : String
  
    var title : String
    var authors : [String]
    var image : UIImage?
    
    init(isbn : String, title : String, authors : [String], image : UIImage? ){
        self.isbn = isbn
        self.title = title
        self.authors = authors
        if (image != nil){
            self.image = image!
        }
    }
}

class TVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var search_txt: UISearchBar!
    
    private var libros : Array<BookSearch> = Array<BookSearch>()
    
    var contexto : NSManagedObjectContext? = nil
    
    func addBockToCell(data: BookSearch) {
        self.libros.append(data)
        tableView.reloadData()
    }
    
    @IBAction func addBook(sender: UIBarButtonItem) {
        search_txt.hidden = false
    }
    override func viewWillDisappear(animated: Bool) {
        search_txt.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search_txt.hidden = true
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        self.title = "Buscador de Libros"
        search_txt.delegate = self
        let uiButton = search_txt.valueForKey("cancelButton") as! UIButton
        uiButton.setTitle("Clear", forState: UIControlState.Normal)
        let seccionEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let peticion = seccionEntidad?.managedObjectModel.fetchRequestTemplateForName("petLibros")
        do{
           let seccionesEntidades = try self.contexto?.executeFetchRequest(peticion!)
            for seccionEntidad2 in seccionesEntidades!{
                let isbn = seccionEntidad2.valueForKey("isbn") as! String
                let title = seccionEntidad2.valueForKey("title") as! String
                var image : UIImage? = nil
                if(seccionEntidad2.valueForKey("image") != nil){
                    image = UIImage(data: seccionEntidad2.valueForKey("image") as! NSData)
                }
                
                let autoresEntidad = seccionEntidad2.valueForKey("tiene") as! Set<NSObject>
                var autores2 = [String]()
                for autorEntidad2 in autoresEntidad{
                    let auth = autorEntidad2.valueForKey("nombre") as! String
                    autores2.append(auth)
                }
                let newBook = BookSearch.init(isbn: isbn, title: title, authors: autores2, image: image)
                self.addBockToCell(newBook)
            }
        }
        catch{
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.libros.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Celda", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = self.libros[indexPath.row].title
        return cell
    }
    
    func getData(isbn isbn:String)->BookSearch?{
        let urls: String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        //let urls: String = "10.10.10.10"
        //let urls: String = "http://dia.ccm.itesm.mx"
        let url = NSURL(string: urls + isbn)
        let datos = NSData(contentsOfURL: url!)
        
        if datos == nil
        {
            let alert = UIAlertController(title: "Error conexión", message: "No hay conexión a internet o el servidor no está accesible.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            do
            {
                let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                let dico1 = json as! NSDictionary
                if dico1["ISBN:"+isbn] != nil
                {
                    let dico2 = dico1["ISBN:"+isbn] as! NSDictionary
                    var new_title : String = ""
                    var new_image : UIImage?
                    var new_authors : [String] = [String]()
                    var image_url : String?
                   
                    //carga el titulo de  el libro
                    if dico2["title"] != nil
                    {
                        new_title =  dico2["title"] as! NSString as String
                    }
                    //carga los autores de libro
                    if dico2["authors"] != nil {
                        let authors = dico2["authors"] as! NSArray
                        if authors.count > 0
                        {
                            for author in authors
                            {
                                new_authors.append( author["name"] as! NSString as String)
                            }
                        }
                    }
                   
                    if dico2["cover"] != nil
                    {
                        let covers = dico2["cover"] as! NSDictionary
                        //muestra portada del de libro
                        if covers["medium"] != nil
                        {
                            image_url = covers["medium"] as! NSString as String
                        }
                        else if covers["small"] != nil
                        {
                            image_url = covers["small"] as! NSString as String
                        }
                        else if covers["large"] != nil
                        {
                            image_url = covers["large"] as! NSString as String
                        }
                        if image_url != nil
                        {
                            let url_img = NSURL(string: image_url!)
                            let data_img = NSData(contentsOfURL: url_img!)
                            //make sure your image in this url does exist, otherwise unwrap in a if let check
                            //-----------
                            new_image = UIImage(data: data_img!)
                        }
                    }
                    let newBook = BookSearch.init(isbn: isbn, title: new_title, authors: new_authors, image: new_image)
                    self.addBockToCell(newBook)
                    return newBook
                }
                else
                {
                    let alert = UIAlertController(title: "ISBN Invalido", message: "No existe este libro en nuestras referencias.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            catch {
            }
        }
        return nil
    }

    func crearAutoresEntidades(autores :[String]) -> Set<NSObject>{
        var entidades = Set<NSObject>()
        for autor in autores{
            let autorEntidad =  NSEntityDescription.insertNewObjectForEntityForName("Autor", inManagedObjectContext: self.contexto!)
            autorEntidad.setValue(autor, forKey: "nombre")
            entidades.insert(autorEntidad)
        }
        return entidades
    }
    
    func search(){
        let seccionEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let peticion = seccionEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("petLibro", substitutionVariables: ["isbn": search_txt.text!])
        do {
            let seccionEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
            if seccionEntidad2?.count > 0 {
                return
            }
        }
        catch{
        }
        let seccion = getData(isbn: search_txt.text!)
        if (seccion != nil){
            let nuevaSeccionEntidad = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
            nuevaSeccionEntidad.setValue(seccion?.isbn, forKey: "isbn")
            nuevaSeccionEntidad.setValue(seccion?.title, forKey: "title")
            if seccion?.image != nil {
                nuevaSeccionEntidad.setValue(UIImagePNGRepresentation((seccion?.image)!), forKey: "image")
            }

nuevaSeccionEntidad.setValue(crearAutoresEntidades((seccion?.authors)!), forKey: "tiene")
            do {
                try self.contexto?.save()
                let detalleViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DetalleViewController") as! DetalleViewController
                detalleViewController.titulo = self.libros.last?.title
                detalleViewController.autores = (self.libros.last?.authors)!
                detalleViewController.imagen = self.libros.last?.image
                self.navigationController?.pushViewController(detalleViewController, animated: true)
            }
            catch{
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        search()
        searchBar.resignFirstResponder() //desaparece el teclado
        search_txt.text = ""
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        search_txt.text = ""
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        search()
        return false
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cl = segue.destinationViewController as! DetalleViewController
        let ip = self.tableView.indexPathForSelectedRow
        if ip != nil {
           cl.titulo = self.libros[ip!.row].title
           cl.autores = self.libros[ip!.row].authors
           cl.imagen = self.libros[ip!.row].image
        }
  
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
