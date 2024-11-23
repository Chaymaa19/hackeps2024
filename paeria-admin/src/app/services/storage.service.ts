import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class StorageService {

  constructor() { }

  private loggedIn: BehaviorSubject<boolean> = new BehaviorSubject<boolean>(false);

  get isLoggedIn() {
    return this.loggedIn.asObservable();
  }

  isLoggedNext(val:boolean) {
    return this.loggedIn.next(val);
  }

  SessionAddStorage(key: string, item: any) : void {
    sessionStorage.setItem(key, JSON.stringify(item));
  }

  SessionGetStorage(key: string) : any {
    const temp = sessionStorage.getItem(key)
    return JSON.parse(temp!)
  }

  SessionRemove(key:string){
    sessionStorage.removeItem(key)
    sessionStorage.clear()
  }

  SessionClear() : any {
    sessionStorage.clear()
    
  }

  LocalAddStorage(key: string, item: any) : void {
    localStorage.setItem(key, JSON.stringify(item));
  }

  LocalGetStorage(key: string) : any {
    const temp = localStorage.getItem(key)
    return JSON.parse(temp!)
  }

  LocalRemove(key:string){
    localStorage.removeItem(key)
  }

  LocalClear() : any {
    const temp = localStorage.clear()
    
  }
}
