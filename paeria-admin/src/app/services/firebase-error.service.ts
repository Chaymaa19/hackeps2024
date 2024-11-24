import { Injectable } from '@angular/core';
import { FirebaseCodeErrorEnum } from '../utils/firebase-code-error';

@Injectable({
  providedIn: 'root'
})
export class FirebaseErrorService {

  constructor() { }

  firebaseError(code: String){
    switch(code){
      //Usuario no encontrado
      case FirebaseCodeErrorEnum.UserNotFound:
        return 'User does not exist'
      //Contraseña Incorrecta
      case FirebaseCodeErrorEnum.WrongPassword:
        return 'Wrong password'
      //Correo existe
      case FirebaseCodeErrorEnum.EmailInUse:
        return 'Email already in use'
      //Weak password
      case FirebaseCodeErrorEnum.WeakPassword:
        return 'Weak password, use 6 characters at least'
      //Correo Invalido
      case FirebaseCodeErrorEnum.BadEmail:
        return 'Invalid Email'
      case FirebaseCodeErrorEnum.InvalidLogin:
        return 'Credentials not accepted'
      //Default
      default:
        return 'Unknown error'
    }

  }
}
