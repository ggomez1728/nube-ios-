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
    
    
    var response : String? = nil

    
    var titulo: String?
    var autores = [String]()
    var imagen: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title_book.text = self.titulo!
        var printauthors :String = ""
        for autor in autores{
            printauthors = printauthors + autor + "\n"
        }
        self.authors_book.text = printauthors
        if imagen != nil {
            imageURL.image = imagen!
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        clear_txt()
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clear_txt(){
        self.title_book.text = ""
        self.authors_book.text = ""
        self.imageURL.image = nil
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
