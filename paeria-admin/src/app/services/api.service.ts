import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { ParkingModel } from '../models/parking.model';
import { OwnerModel } from '../models/owner.model';



@Injectable({
  providedIn: 'root'
})
export class ApiService {

  private apiUrl = 'http://172.20.10.6:5000/'

  constructor(private http: HttpClient) {
  }

  getOwners():Promise<OwnerModel[]>{
    return new Promise((resolve, reject) => {
      this.http.get<OwnerModel[]>(this.apiUrl + 'owners')
        .subscribe(
          (response: OwnerModel[]) => {
            resolve(response);
          },
          (error) => {
            reject(error);
          }
        );
    });
  }

  getParkings(uid: string): Promise<ParkingModel[]> {
    if (uid == "oevU131oRfRtp17iB4m3aiZiOUS2"){
      return new Promise((resolve, reject) => {
        this.http.get<ParkingModel[]>(this.apiUrl + 'parkings')
          .subscribe(
            (response: ParkingModel[]) => {
              resolve(response);
            },
            (error) => {
              reject(error);
            }
          );
      });
    }else{
      return new Promise((resolve, reject) => {
        this.http.get<ParkingModel[]>(this.apiUrl + 'parkings/owner/'+ uid)
          .subscribe(
            (response: ParkingModel[]) => {
              resolve(response);
            },
            (error) => {
              reject(error);
            }
          );
      });
    }
    
  }

}
