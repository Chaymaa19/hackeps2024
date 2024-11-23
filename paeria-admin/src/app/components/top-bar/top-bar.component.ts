import { Component, HostListener } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { Router } from '@angular/router';
import { Subscription, Observable } from 'rxjs';
import { StorageService } from '../../services//storage.service';
import { ApiService } from '../../services/api.service';

@Component({
  selector: 'app-top-bar',
  templateUrl: './top-bar.component.html',
  styleUrls: ['./top-bar.component.css']
})
export class TopBarComponent {
  
  prevScrollPos = window.pageYOffset;
  showPopup = false;
  showNotis = false;
  notifications: string[] = [];

  constructor(private afAuth: AngularFireAuth, private router: Router, private storageService: StorageService,
    private api: ApiService) {
    
  }

  logout() {
    this.afAuth.signOut().then(() => {
      this.storageService.isLoggedNext(false);
      localStorage.clear();
      this.router.navigate(['/']);
    })
  }


}
