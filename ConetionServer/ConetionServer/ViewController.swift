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
    @IBOutlet weak var search_txt: UISearchBar!
    
    @IBOutlet weak var output_text: UITextView!
    var response : String? = nil
    
    func sincrono(ISBN:String){
        let urls: String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(ISBN)"
        //let urls: String = "10.10.10.10"

        //let urls: String = "http://dia.ccm.itesm.mx"
        let url = NSURL(string: urls)
        print(urls)
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
    
    func search(){
        sincrono(self.search_txt.text!)
        self.output_text.text = self.response
    }
    
    func asincrono() {
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:\(self.response)"
        //let urls = "http://dia.ccm.itesm.mx"
        print(urls)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        search_txt.delegate = self
        let uiButton = search_txt.valueForKey("cancelButton") as! UIButton
        uiButton.setTitle("Clear", forState: UIControlState.Normal)
        
        self.response = "978-84-376-0494-7"
        search_txt.text = self.response
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        search()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        output_text.text = ""
        search_txt.text = ""
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        search()
        return false
    }
}

