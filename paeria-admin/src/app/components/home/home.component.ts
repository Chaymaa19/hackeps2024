import { Component, OnInit, OnDestroy, ChangeDetectorRef } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { Router } from '@angular/router';
import { StorageService } from '../../services/storage.service';
import { ApiService } from '../../services/api.service';
import { ParkingModel } from '../../models/parking.model';
import { OwnerModel } from '../../models/owner.model';
import { ChartData, ChartOptions } from 'chart.js';
import { AngularFireDatabase } from '@angular/fire/compat/database'; // Firebase Realtime Database import
import { Subscription } from 'rxjs'; // To handle subscription for live updates
import { AngularFirestore } from '@angular/fire/compat/firestore';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit, OnDestroy {

  pieChartData: ChartData<'doughnut'> = {
    labels: ['Filled', 'Empty'],
    datasets: [{
      data: [0, 0]  // Initial empty data
    }]
  };

  barChartData: ChartData<'bar'> = {
    labels: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
    datasets: [{
      data: [30, 45, 65, 40, 50, 75, 30]  // Example data for time spent each day
    }]
  };

  chartOptions: ChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false  // Hide the legend
      },
    },
  };

  parkings: ParkingModel[] = [];
  owners: OwnerModel[] = [];
  selectedParkingId: string | null = null;  // Track the selected parking by ID
  parkingSubscription: Subscription | null = null; // Firebase subscription

  constructor(
    private afAuth: AngularFireAuth,
    private router: Router,
    private storageService: StorageService,
    private api: ApiService,
    private firestore: AngularFirestore,
    private cdr: ChangeDetectorRef
  ) { }

  ngOnInit(): void {
    this.parkings = this.storageService.SessionGetStorage("parkings");
    this.owners = this.storageService.SessionGetStorage("owners");

    this.translateOwnerUIDToName();

    // Listen for live updates of parking data from Firebase using snapshots
    this.listenForParkingUpdates();
  }

  ngOnDestroy(): void {
    // Unsubscribe from Firebase to prevent memory leaks
    if (this.parkingSubscription) {
      this.parkingSubscription.unsubscribe();
    }
  }

  // Method to check if a parking's details should be visible
  isParkingSelected(parking: ParkingModel): boolean {
    return this.selectedParkingId === parking.id;
  }

  // Method to toggle the details for a specific parking
  toggleDetails(parking: ParkingModel): void {
    if (this.selectedParkingId === parking.id) {
      this.selectedParkingId = null;  // Hide details if the same parking is clicked again
    } else {
      this.selectedParkingId = parking.id ?? null;
    }

    if (this.selectedParkingId) {
      this.updateChartData(parking);
    }
  }

  // Method to translate the owner UID to the owner name
  translateOwnerUIDToName(): void {
    this.parkings.forEach(parking => {
      if (parking.owner) {
        const owner = this.owners.find(owner => owner.uid === parking.owner);
        if (owner) {
          parking.owner = owner.name;
        }
      }
    });
  }

  // Method to update the chart data based on the parking's spot data
  updateChartData(parking: ParkingModel): void {
    if (!parking.spots) return;
  
    const filledCount = parking.spots.filter(spot => spot.filled).length;
    const emptyCount = parking.spots.length - filledCount;
  
    this.pieChartData = {
      labels: ['Filled', 'Empty'],
      datasets: [{
        data: [filledCount, emptyCount],
        backgroundColor: [
          'rgba(255, 0, 0, 0.7)',  // Red color for Filled
          'rgba(0, 255, 0, 0.7)'   // Green color for Empty
        ]
      }]
    };
  }

  listenForParkingUpdates(): void {
    // Fetch parking data from Firestore in real-time
    this.parkingSubscription = this.firestore.collection<ParkingModel>('parkings').snapshotChanges()
      .subscribe(snapshot => {
        // Transform the Firestore snapshot data into ParkingModel array
        const updatedParkings = snapshot.map(doc => {
          const data = doc.payload.doc.data() as ParkingModel;
          data.id = doc.payload.doc.id;
          return data;
        });
  
        // Replace the entire parkings array to trigger Angular change detection
        this.parkings = updatedParkings;
  
        // Translate the owner UID to owner name
        this.translateOwnerUIDToName();
  
        // Manually trigger change detection after updating the data
        this.cdr.detectChanges(); // This forces Angular to update the view
  
        // Update charts for all parkings or the selected one
        if (this.selectedParkingId) {
          // If a parking is selected, update its chart data
          const selectedParking = this.parkings.find(p => p.id === this.selectedParkingId);
          if (selectedParking) {
            this.updateChartData(selectedParking);
          }
        } else {
          // Update charts for all parkings
          this.parkings.forEach(parking => {
            this.updateChartData(parking);
          });
        }
      });
  }
  

  
  

  logout(): void {
    this.afAuth.signOut().then(() => {
      this.storageService.isLoggedNext(false);
      sessionStorage.clear();
      localStorage.clear();
      this.router.navigate(['/']);
    });
  }

  exportCSV(): void {
    const parkingData = this.parkings.map(parking => ({
      Name: parking.name,
      Address: parking.address,
      Owner: parking.owner,
      Spots: parking.spots!.length,
      FilledSpots: parking.spots!.filter(spot => spot.filled).length,
      EmptySpots: parking.spots!.length - parking.spots!.filter(spot => spot.filled).length
    }));

    const headers = ['Name', 'Address', 'Owner', 'Total Spots', 'Filled Spots', 'Empty Spots'];
    const csvRows = [];
    csvRows.push(headers.join(','));

    for (const row of parkingData) {
      csvRows.push(Object.values(row).join(','));
    }

    const csvContent = csvRows.join('\n');
    this.downloadCSV(csvContent);
  }

  downloadCSV(csvContent: string): void {
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    if (link.download !== undefined) {
      const fileName = 'parking_data.csv';
      link.setAttribute('href', URL.createObjectURL(blob));
      link.setAttribute('download', fileName);
      link.style.visibility = 'hidden';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  }
}
