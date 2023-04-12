//
//  SimpleTableViewController.swift
//  MedicosServices
//
//  Created by soliduSystem on 11/04/23.
//

import UIKit

class SimpleTableViewController: UITableViewController {
    
    public var token: String?
    public var refreshToken: String?
    public var userId: Int?
    public var urlApi: String = "http://192.168.1.142:12182256/api/v1"
    public var phoneNumber: String = "8712655150"
    public var uniqueDates: [dataTabel] = [dataTabel]()
    public var dataSourcePatitnes: [ResponsePatientsData] = [ResponsePatientsData]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.register(UINib(nibName: "MyCellTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
        self.tableView.rowHeight = 60.0
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let credentials = HttpBodyLogin(uuid: UUID().uuidString, password: "uno")
        
        self.PostLogin(with: credentials)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.uniqueDates.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.uniqueDates[section].data.count
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.uniqueDates[section].uniqueDates
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyCellTableViewCell
        
        cell.dateLable.text = "\(self.uniqueDates[indexPath.section].data[indexPath.row].date) \(self.uniqueDates[indexPath.section].data[indexPath.row].time)"
        
        cell.nameLable.text = self.uniqueDates[indexPath.section].data[indexPath.row].patientLastName == nil ? "" : "\(self.uniqueDates[indexPath.section].data[indexPath.row].patientName!)"
        
        cell.tag = self.uniqueDates[indexPath.section].data[indexPath.row].id
        
        
        cell.imgView.image = UIImage(systemName: "")

        if ((self.uniqueDates[indexPath.section].data[indexPath.row].patientName?.isEmpty) != nil) {
            if self.uniqueDates[indexPath.section].data[indexPath.row].confirmed {
                cell.backgroundColor =  UIColor.black.withAlphaComponent(0.1)
                cell.imgView.image = UIImage(systemName: "checkmark.circle")
                cell.imgView.tintColor = UIColor.green.withAlphaComponent(0.5)
                
                
            } else if !self.uniqueDates[indexPath.section].data[indexPath.row].confirmed {
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.1)
                cell.imgView.image = UIImage(systemName: "checkmark.circle.trianglebadge.exclamationmark")
                cell.imgView.tintColor = UIColor.yellow.withAlphaComponent(0.5)

                
            }
        }
        
        
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if self.uniqueDates.isEmpty {
            return
        }
        
        
        let actionAC = UIAlertController(title: "Elige lo que quieres hacer", message: "message", preferredStyle: .actionSheet)
        
        if ((self.uniqueDates[indexPath.section].data[indexPath.row].patientName?.isEmpty) == nil) && !self.uniqueDates[indexPath.section].data[indexPath.row].confirmed {
            //NO ESTA REGISTRAOD NADIE
            print("NO ESTA REGISTRAOD NADIE")
            
            actionAC.addAction(UIAlertAction(title: "Agregar Paciente", style: .default, handler: { UIAlertAction in
                
                self.aggPaciente(IdCita: tableView.cellForRow(at: indexPath)!.tag)
                
            }))

            
            
        } else if ((self.uniqueDates[indexPath.section].data[indexPath.row].patientName?.isEmpty) != nil) && !self.uniqueDates[indexPath.section].data[indexPath.row].confirmed {
            //TIENE UNA SITA PERO NO ESTA CONFIGMADA
            print("TIENE UNA SITA PERO NO ESTA CONFIGMADA")
            
            actionAC.addAction(UIAlertAction(title: "Confirmar Cita", style: .default, handler: { UIAlertAction in
                self.PatchConfirmAppointment(By: tableView.cellForRow(at: indexPath)!.tag)
            }))
            
            
            
        } else if ((self.uniqueDates[indexPath.section].data[indexPath.row].patientName?.isEmpty) != nil) && self.uniqueDates[indexPath.section].data[indexPath.row].confirmed {
            //ESTA CONFIRMADA LA PODEMS CANCELAR
            print("ESTA CONFIRMADA LA PODEMS CANCELAR")
            
            actionAC.addAction(UIAlertAction(title: "Cancelar Cita", style: .default, handler: { UIAlertAction in
                self.PatchCancelAppointment(By: tableView.cellForRow(at: indexPath)!.tag, body: HttpBodyCancelAppointment(disable: false))
            }))
            
            
        }
        
        actionAC.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.present(actionAC, animated: true)

        
    }
    
    
    private func aggPaciente(IdCita: Int) {
        
        let actionACPaciente = UIAlertController(title: "Pacientes", message: "Elige un paciente", preferredStyle: .actionSheet)
        
        for pct in self.dataSourcePatitnes {
            actionACPaciente.addAction(UIAlertAction(title: "\(pct.name) \(pct.last_name)", style: .default, handler: { UIAlertAction in
                
                self.PostReserveAppointment(By: IdCita, to: HttpBodyReserveAppointment(userId: pct.id))
                
            }))
        }
        

        actionACPaciente.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        self.present(actionACPaciente, animated: true)
        
    }
    
}






extension SimpleTableViewController {
    
    private func PostLogin(with credentials: HttpBodyLogin){
        
        let url =  URL(string: "\(self.urlApi)/auth/login")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(credentials)
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        print("::: NEW httpBody : \(request.httpBody!) :::")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if (response as! HTTPURLResponse).statusCode == 200 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    do {
                        let response = try JSONDecoder().decode(ResponseLogin.self, from: data)
                        print("Respuesta JSON: \(response)")
                        
                        //TENEMOS UN TOKEN Y PODEMOS CONSUMIR LOS DEMAS SERVICIOS
                        
                        self.token = response.data.auth.token
                        self.refreshToken = response.data.auth.refreshToken
                        self.userId = response.data.userId
                        
                        self.GetUser(By: self.phoneNumber)
                        
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                 DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
            }
            
        }.resume()
        
    }
    
    
    
    private func GetUser(By PhoneNumber: String){
        
        let url =  URL(string: "\(self.urlApi)/users/phone/+52\(PhoneNumber)")!
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if (response as! HTTPURLResponse).statusCode == 200 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    do {
                        let response = try JSONDecoder().decode(ResponseGerUserByPhoneNumber.self, from: data)
                        print("Respuesta JSON: \(response)")
                        
                        //TENEMOS EL CODIGO QUE SE ENVIA AL USUARIO CUANDO SE REGISTRA CON SU NUMERO
                        self.userId = response.data.id
                        let code = HttpBodyCheckCode(id: response.data.id, code: response.data.code)
                        
                        //verificar codigo
                        self.PostCheck(Code: code)
                        
                        
                        
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                 DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
                
                if let stringData = String(data: data!, encoding: .utf8) {
                    print("Respuesta de la API:")
                    print(stringData)
                } else {
                    print("Error: No se pudo convertir el objeto Data a una cadena de texto")
                }
                
            }
            
        }.resume()
        
    }
    
    
    
    private func PostCheck(Code code: HttpBodyCheckCode){
        
        let url =  URL(string: "\(self.urlApi)/auth/code")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(code)
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        print("::: NEW httpBody : \(request.httpBody!) :::")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if (response as! HTTPURLResponse).statusCode == 200 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    do {
                        let response = try JSONDecoder().decode(ResponseCheckCode.self, from: data)
                        print("Respuesta JSON: \(response)")
                        
                        //TENEMOS EL CODIGO QUE SE ENVIA AL USUARIO CUANDO SE REGISTRA CON SU NUMERO
                        self.userId = response.data.userId
                        self.token = response.data.auth.token
                        self.refreshToken = response.data.auth.refreshToken
                        
                        //HCAER UN REFRES TOKEN
                        
                        let tokenRef = HttpBodyRefreshToken(refreshToken: self.refreshToken!)
                        
                        self.PostRefresh(tokenRef)
                        
                        
                        
                        
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                 DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
            }
            
        }.resume()
        
    }
    
    
    private func PostRefresh(_ token: HttpBodyRefreshToken){
        
        let url =  URL(string: "\(self.urlApi)/auth/refresh")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(token)
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        print("::: NEW httpBody : \(request.httpBody!) :::")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if (response as! HTTPURLResponse).statusCode == 200 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    do {
                        let response = try JSONDecoder().decode(ResponseLogin.self, from: data)
                        print("Respuesta JSON: \(response)")
                        
                        //TENEMOS EL CODIGO QUE SE ENVIA AL USUARIO CUANDO SE REGISTRA CON SU NUMERO
                        self.userId = response.data.userId
                        self.token = response.data.auth.token
                        self.refreshToken = response.data.auth.refreshToken
                        
                        //HCAER UN REFRES TOKEN
                        
                        self.GetSchedule()
                        self.GetPatients()
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                 DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
            }
            
        }.resume()
        
    }
    
    
    private func GetSchedule(){
        
        let url =  URL(string: "\(self.urlApi)/schedule")!
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if (response as! HTTPURLResponse).statusCode == 200 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    do {
                                                                        
                        let response = try JSONDecoder().decode(ResponseGetSchedule.self, from: data)
                        
                        print("Respuesta JSON: \(response.data.count)")
                    
                        
                        //TENEMOS EL CODIGO QUE SE ENVIA AL USUARIO CUANDO SE REGISTRA CON SU NUMER
                        
                        self.uniqueDates.removeAll()
                        
                        for uniqueDate in Array(Set(response.data.map({ $0.date }))).sorted() {
                            self.uniqueDates.append(
                                dataTabel(
                                    uniqueDates: uniqueDate,
                                    data: response.data.filter({$0.date == uniqueDate}))
                            )
                        }
                        
                        
                        print("\n\n\n")
                        print(self.uniqueDates)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                                        
                        
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                 DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
                
                if let stringData = String(data: data!, encoding: .utf8) {
                    print("Respuesta de la API:")
                    print(stringData)
                } else {
                    print("Error: No se pudo convertir el objeto Data a una cadena de texto")
                }
                
            }
            
        }.resume()
        
    }
    
    private func GetPatients(){
        
        let url =  URL(string: "\(self.urlApi)/users/patients")!
        
        print(url)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if (response as! HTTPURLResponse).statusCode == 200 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    do {
                        
                        let response = try JSONDecoder().decode(ResponsePatients.self, from: data)
                        
                        
                        let patientsActive = response.data.filter { PatientsStatus in
                            return PatientsStatus.active && !PatientsStatus.assistant
                        }
                        
                        self.dataSourcePatitnes.append(contentsOf: patientsActive)
                        
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                 DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
                
                if let stringData = String(data: data!, encoding: .utf8) {
                    print("Respuesta de la API:")
                    print(stringData)
                } else {
                    print("Error: No se pudo convertir el objeto Data a una cadena de texto")
                }
                
            }
            
        }.resume()
        
    }
    
    
    
    struct dataTabel: Codable {
        var uniqueDates: String
        var data: [ResponseGetScheduleData] = [ResponseGetScheduleData]()
    }
    
    
    
    private func PostReserveAppointment(By id: Int, to user: HttpBodyReserveAppointment){
        
        let url =  URL(string: "\(self.urlApi)/appointments/reserve/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(user)
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        print("::: NEW httpBody : \(request.httpBody!) :::")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            print(String(data: data!, encoding: .utf8))
            
            if (response as! HTTPURLResponse).statusCode == 201 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    do {
                        let response = try JSONDecoder().decode(ResponsePostReserveAppointment.self, from: data)
                        print("Respuesta JSON: \(response)")
                        
                        //TENEMOS EL CODIGO QUE SE ENVIA AL USUARIO CUANDO SE REGISTRA CON SU NUMERO
                        self.GetSchedule()
                        
                        //HCAER UN REFRES TOKEN
                        
                        
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                 DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
            }
            
        }.resume()
        
    }
    
    
    
    
    private func PatchConfirmAppointment(By id: Int){
        
        let url =  URL(string: "\(self.urlApi)/appointments/confirm/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            print(String(data: data!, encoding: .utf8))

            
            if (response as! HTTPURLResponse).statusCode == 200 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    do {
                        let response = try JSONDecoder().decode(ResponsePostConfirmAppointment.self, from: data)
                        print("Respuesta JSON: \(response)")
                        
                        //TENEMOS EL CODIGO QUE SE ENVIA AL USUARIO CUANDO SE REGISTRA CON SU NUMERO
                        self.GetSchedule()
                        
                        //HCAER UN REFRES TOKEN
                        
                        
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
            }
            
        }.resume()
        
    }
    
    
    private func PatchCancelAppointment(By id: Int, body: HttpBodyCancelAppointment){
        
        let url =  URL(string: "\(self.urlApi)/appointments/cancel/\(id)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(body)
        
        print("\n\n")
        print("::: NEW REQUEST : \(request.url!) :::")
        print("::: NEW httpMethod : \(request.httpMethod!) :::")
        print("::: NEW httpBody : \(request.httpBody!) :::")
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            
            print(String(data: data!, encoding: .utf8))

            
            if (response as! HTTPURLResponse).statusCode == 200 {
                //EL SERVIDOR RESPONSE CON == 200
                if let data = data {
                    
                    
                    do {
                        let response = try JSONDecoder().decode(ResponsePostCancelAppointment.self, from: data)
                        print("Respuesta JSON: \(response)")
                        
                        //TENEMOS EL CODIGO QUE SE ENVIA AL USUARIO CUANDO SE REGISTRA CON SU NUMERO
                        self.GetSchedule()
                        
                        //HCAER UN REFRES TOKEN
                        
                        
                        
                    } catch {
                        print("Error al parsear la respuesta JSON: \(error.localizedDescription)")
                    }
                }
                
            } else {
                //EL SERVIDOR RESPONSE CON != 200
                 DispatchQueue.main.async {
                    print((response as! HTTPURLResponse).statusCode)
                    let ac = UIAlertController(title: "\(String(describing: String(data: data!, encoding: .utf8)))", message: "", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(ac, animated: true)
                }
            }
            
        }.resume()
        
    }
    
    
    
}


struct ResponsePatients: Codable {
    let msg: String
    let data: [ResponsePatientsData]
}


struct ResponsePatientsData: Codable {
    let id: Int
    let assistant: Bool
    let active: Bool
    let name: String
    let last_name: String
}


//LOGIN
struct HttpBodyLogin: Codable {
    let uuid: String
    let password: String
}



struct ResponseLogin: Codable {
    let msg: String
    let data: ResponseAuthLogin
}

struct ResponseAuthLogin: Codable {
    let auth: ResponseToken
    let userId: Int
}

struct ResponseToken: Codable{
    let type: String
    let token: String
    let refreshToken: String
}
//END LOGIN



//USER BY PHONE NUMBER
struct ResponseGerUserByPhoneNumber: Codable {
    let msg: String
    let data: ResponseDataUserByPhoneNumber
}

struct ResponseDataUserByPhoneNumber:Codable {
    let id: Int
    let registered: Bool
    let code: String
}
//END USER BY PHONE NUMBER


//CHECK CODE
struct HttpBodyCheckCode: Codable {
    let id: Int
    let code: String
}


struct ResponseCheckCode: Codable {
    let msg: String
    let data: ResponseCheckCodeData
}

struct ResponseCheckCodeData: Codable{
    let matches: Bool
    let role: Int
    let userId: Int
    let auth: ResponseToken
}
//END CHECK CODE



//REFRESH TOKEN
struct HttpBodyRefreshToken: Codable {
    let refreshToken: String
}
//END REFRESH TOKEN



// GET SCHEDULE
struct ResponseGetSchedule:Codable {
    let msg: String
    let data: [ResponseGetScheduleData]
}

struct ResponseGetScheduleData: Codable{
    let id: Int
    let date: String
    let time: String
    let confirmed: Bool
    let patientPhone: String?
    let patientName: String?
    let patientLastName: String?
}
//END GET SCHEDULE


//POST RESERAVE APPOINTMENT
struct HttpBodyReserveAppointment: Codable {
    let userId: Int
}

struct ResponsePostReserveAppointment:Codable {
    let msg: String
    let data: Int?
}
//POST RESERAVE APPOINTMENT




//POST CONFIRM APPOINTMENT
struct ResponsePostConfirmAppointment:Codable {
    let msg: String
    let data: ResponsePostConfirmAppointmentData
}

struct ResponsePostConfirmAppointmentData: Codable{
    let confirmed: Bool
}
//POST CONFIRM APPOINTMENT



//POST CANCEL APPOINTMENT
struct HttpBodyCancelAppointment: Codable {
    let disable: Bool
}

struct ResponsePostCancelAppointment:Codable {
    let msg: String
    let data: ResponsePostCancelAppointmentData
}

struct ResponsePostCancelAppointmentData: Codable {
    let canceled: Bool
    let disabled: Bool
}
//POST CANCEL APPOINTMENT
