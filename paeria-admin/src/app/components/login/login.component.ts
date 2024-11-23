import { Component } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';
import { FirebaseErrorService } from '../../services/firebase-error.service';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { StorageService } from '../../services/storage.service';
import { Subscription } from 'rxjs';
import { ApiService } from '../../services/api.service';
import { FirestoreService } from '../../services/firestore.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent {
  loginUser: FormGroup;
  subscription: Subscription;

  constructor(private fb: FormBuilder, private afAuth: AngularFireAuth, public router: Router,
              private fireBaseErrorService: FirebaseErrorService, private toastr: ToastrService, 
              private storageService: StorageService, private apiService: ApiService) {
    this.loginUser = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', Validators.required]
    });

    this.subscription = this.storageService.isLoggedIn
      .subscribe(data => {
        if (data) {
          this.router.navigate(['home']);
        }
      });

    this.checkSession();
  }

  checkSession() {
    const email = localStorage.getItem('usrMail') || '';
    const pswd = localStorage.getItem('usrPswd') || '';
    this.login(email, pswd, true);
  }

  login(localEmail: string, localPassword: string, fromCookies: boolean) {
  let email = this.loginUser.value.email;
  let password = this.loginUser.value.password;

  if (fromCookies) {
    if (localEmail === "" || localPassword === "") {
      return;
    } else {
      email = localEmail;
      password = localPassword;
    }
  }

  this.afAuth.signInWithEmailAndPassword(email, password).then((user) => {
    if (user.user) {
      const uid = user.user.uid;

      // Save credentials in localStorage
      localStorage.setItem('usrPswd', password);
      localStorage.setItem('usrMail', email);
      
      this.storageService.SessionAddStorage("uid", uid);

      // Fetch parking data and wait for it to be saved before navigating
      this.apiService.getParkings(uid).then((data) => {
        
        this.storageService.SessionAddStorage("parkings", data);

        this.apiService.getOwners().then((owner) => {

          this.storageService.SessionAddStorage("owners", owner);
          this.storageService.isLoggedNext(true);
          this.router.navigate(['home']);
          
        }).catch((error) => {
          this.toastr.error('Failed to load parking data', 'Error');
          console.error("Error fetching parking data:", error);
        });
        
      }).catch((error) => {
        this.toastr.error('Failed to load parking data', 'Error');
        console.error("Error fetching parking data:", error);
      });
    }
  }).catch((error) => {
    this.toastr.error(this.fireBaseErrorService.firebaseError(error.code), 'Error');
  });
}

}
