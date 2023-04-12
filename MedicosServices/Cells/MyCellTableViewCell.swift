//
//  MyCellTableViewCell.swift
//  MedicosServices
//
//  Created by soliduSystem on 12/04/23.
//

import UIKit

class MyCellTableViewCell: UITableViewCell {
    
    /*awakeFromNib(): Este método es llamado cuando la celda es creada desde un archivo de interfaz (nib) y cargada en memoria. Puede ser utilizado para realizar configuraciones iniciales, establecer propiedades, y realizar otras tareas de inicialización.*/
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.nameLable.text = ""
        self.dateLable.text = ""
        
    }
    
    /*setSelected(_:animated:): Este método es llamado cuando la celda es seleccionada o deseleccionada en la tabla. Se puede utilizar para realizar acciones especiales cuando una celda es seleccionada, como cambiar la apariencia de la celda o realizar alguna acción relacionada.*/
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }

    
    /*prepareForReuse(): Este método es llamado cuando la celda está siendo preparada para ser reutilizada en otra fila de la tabla. Se puede utilizar para reiniciar las propiedades y estados de la celda antes de ser mostrada con nuevos datos.*/
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("prepareForReuse")
        
        self.backgroundColor = UIColor.white
        
    }
        
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var dateLable: UILabel!
}
