import { Injectable } from '@angular/core';
import { Firestore, collection, getDocs, query, where } from 'firebase/firestore';
import { getFirestore } from '@angular/fire/firestore';  // New Firestore initialization
import { environment } from '../../enviroments/enviroments';  // Assuming you have Firebase config in environment

import { Observable, from } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class FirestoreService {
  firestore: Firestore;

  constructor() {
    // Initialize Firestore using the Firebase app config
    this.firestore = getFirestore();
  }

  // Fetch all users from the "Parking" collection
  getUsers(): Observable<any[]> {
    const usersCollection = collection(this.firestore, 'Parking');
    return from(getDocs(usersCollection).then(snapshot => {
      const usersList = snapshot.docs.map(doc => doc.data());
      return usersList;
    }));
  }

  // Query example: Fetch users with certain condition (e.g., age > 30)
  getUsersWithCondition(): Observable<any[]> {
    const parkingCollection = collection(this.firestore, 'Parking');
    const q = query(parkingCollection, where('age', '>', 30));

    return from(getDocs(q).then(snapshot => {
      const usersList = snapshot.docs.map(doc => doc.data());
      return usersList;
    }));
  }
}
