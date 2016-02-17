//
//  ViewController.swift
//  ConetionServer
//
//  Created by Pollinion User on 10/02/16.
//  Copyright © 2016 Pollinion INC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate {

    /* en Info.plisp
    <key>NSAppTransportSecurity</key>
    <dict>
    <!--Permite todas las conexiones (cuidado) -->
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    </dict>
    
    ó
    
    <key>NSAppTransportSecurity</key>
    <dict>
    <key>NSExceptionDomains</key>
    <dict>
    <key>dia.ccm.itesm.mx</key>
    <dict>
    <!--Incluir todos los subdominios-->
    <key>NSIncludesSubdomains</key>
    <true/>
    <!--Para que se pueda realizar peticiones HTTP-->
    <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
    <true/>
    </dict>
    </dict>
    </dict>
    */
    
    @IBOutlet weak var title_book: UITextView!
    @IBOutlet weak var authors_book: UITextView!
    @IBOutlet weak var imageURL: UIImageView!
    

    @IBOutlet weak var search_txt: UISearchBar!
    @IBOutlet weak var output_text: UITextView!
    var response : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        search_txt.delegate = self
        let uiButton = search_txt.valueForKey("cancelButton") as! UIButton
        uiButton.setTitle("Clear", forState: UIControlState.Normal)
        
        //self.response = "978-84-376-0494-7"
        
        self.response = "9788426816382"
        search_txt.text = self.response
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
    
    func search(){
        //sincrono(self.search_txt.text!)
        getData(isbn: search_txt.text!)
    }

   
    func clear_txt(){
        self.title_book.text = ""
        self.authors_book.text = ""
        self.imageURL.image = nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func sincrono(ISBN:String){
        let urls: String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(ISBN)"
        //let urls: String = "10.10.10.10"
        
        //let urls: String = "http://dia.ccm.itesm.mx"
        let url = NSURL(string: urls)
        let datos:NSData? = NSData(contentsOfURL: url!)
        if datos == nil
        {
            self.response = "SIN CONEXION!"
        }
        else
        {
            let texto = NSString(data: datos!, encoding:NSUTF8StringEncoding)
            self.response = String(texto!)
        }
    }

    func downloadBookDataWith(isbn isbn: String) {
        let urlString = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(isbn)"
        //let urlString = "10.10.10.10"

        let url = NSURL(string: urlString)
        if let url = url {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                guard data != nil && error == nil else {
                    self.updateResultTextView("")
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        let alert = UIAlertController(title: "Error conexión", message: "No hay conexión a internet o el servidor no está accesible.", preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    return
                }
                let json = String(data: data!, encoding: NSUTF8StringEncoding)
                if let json = json {
                    self.updateResultTextView(json)
                } else {
                    self.updateResultTextView("Ha ocurrido un error")
                }
            })
            task.resume()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        } else {
            // Error building endpoint
            self.output_text.text = "Ha ocurrido un error generando la url \n \(urlString)"
        }
    }
    
    func updateResultTextView(text: String) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.output_text.text = text
        }
    }
    
    func asincrono() {
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(self.response)"
        //let urls = "http://dia.ccm.itesm.mx"
        let url = NSURL(string: urls)
        let sesion = NSURLSession.sharedSession()
        let bloque = {(datos: NSData?, resp : NSURLResponse?, error : NSError?) -> Void in
            let texto = NSString(data: datos!, encoding: NSUTF8StringEncoding)
            self.response = String(texto!)
            self.output_text.text = self.response
        }
        let dt = sesion.dataTaskWithURL(url!, completionHandler: bloque)
        dt.resume()
    }
    
   */
}

