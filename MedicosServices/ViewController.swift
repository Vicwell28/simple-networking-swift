//
//  ViewController.swift
//  MedicosServices
//
//  Created by soliduSystem on 10/04/23.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Override Func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uuid = UUID().uuidString
        let password = "12182256"
        
        self.PostLogin(uuid: uuid, password: password)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    
    // MARK: - IBOutlet
    
    
    // MARK: - Public let / var
    
    
    // MARK: - Private let / var
    
    
    // MARK: - IBAction
    
}



// MARK: - Public Func
extension ViewController {
    
}

// MARK: - Private Func
extension ViewController {
    
}

// MARK: - Services
extension ViewController {
    
    private func PostLogin(uuid: String, password: String){
        
        print("uuid: \(uuid)")
        
        // Crear la URL del endpoint de la API para el login
        guard let url = URL(string: "") else {
            return
        }

        // Crear la solicitud URLRequest con el método POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Crear el cuerpo de la solicitud con los datos de inicio de sesión
        let params = ["uuid": uuid, "password": password]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Crear una sesión URLSession
        let session = URLSession.shared

        // Crear una tarea de dataTask con la solicitud
        let task = session.dataTask(with: request) { data, response, error in
            // Manejar la respuesta de la API
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Error: No se recibió ningún dato.")
                return
            }

            // Parsear los datos de la respuesta
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("Respuesta: \(json)")
                // Aquí puedes procesar la respuesta de la API y realizar acciones en consecuencia, como guardar el token de autenticación, actualizar la UI, etc.
            } catch {
                print("Error al parsear los datos de respuesta: \(error.localizedDescription)")
            }
        }

        // Iniciar la tarea
        task.resume()
    }
    
}

// MARK: - Other
extension ViewController {
    
}
