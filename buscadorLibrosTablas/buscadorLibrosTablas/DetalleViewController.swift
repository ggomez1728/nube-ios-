//
//  DetalleViewController.swift
//  buscadorLibrosTablas
//
//  Created by Pollinion User on 29/02/16.
//  Copyright © 2016 Pollinion INC. All rights reserved.
//

import UIKit
// protocol used for sending data back

protocol AcceptDataFromDetalleVC {
    func acceptDataFromDetalle (data:Array<String>)
}

class DetalleViewController: UIViewController, UISearchBarDelegate {

    var delegate: AcceptDataFromDetalleVC? = nil
    
    @IBOutlet weak var title_book: UITextView!
    @IBOutlet weak var authors_book: UITextView!
    @IBOutlet weak var imageURL: UIImageView!
    
    
    @IBOutlet weak var search_txt: UISearchBar!
    var response : String? = nil

    
    var esBusqueda: Bool = false
    var ISBN: String?
    var titulo: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search_txt.delegate = self
        let uiButton = search_txt.valueForKey("cancelButton") as! UIButton
        uiButton.setTitle("Clear", forState: UIControlState.Normal)
        if esBusqueda == false{
            search_txt.hidden=true
            getData(isbn: self.ISBN!)
        }
      

        self.title = ""
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.esBusqueda
        {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getData(isbn isbn:String){
        let urls: String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        //let urls: String = "10.10.10.10"
        
        //let urls: String = "http://dia.ccm.itesm.mx"
        clear_txt()
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
                    let authors = dico2["authors"] as! NSArray
                    //imprime el titulo de  el libro
                    if dico2["title"] != nil
                    {
                        self.title_book.text =  dico2["title"] as! NSString as String
                    }
                    //imprime los autores de libro
                    if authors.count > 0
                    {
                        var name: String?
                        for author in authors
                        {
                            name = author["name"] as! NSString as String
                            self.authors_book.text = "\(self.authors_book.text)- \(name!) \n"
                        }
                    }
                    if dico2["cover"] != nil
                    {
                        let covers = dico2["cover"] as! NSDictionary
                        var image_url : String?
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
                            self.imageURL.image = UIImage(data: data_img!)
                        }
                    }
                    if esBusqueda {
                        delegate?.acceptDataFromDetalle([isbn , self.title_book.text])
                    }
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
    }
    
    func clear_txt(){
        self.title_book.text = ""
        self.authors_book.text = ""
        self.imageURL.image = nil
    }
    
    func search(){
        //sincrono(self.search_txt.text!)
        getData(isbn: search_txt.text!)
    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        search()
        searchBar.resignFirstResponder() //desaparece el teclado
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        search_txt.text = ""
        clear_txt()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        search()
        return false
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
