import { Component, OnInit } from '@angular/core';
import { AngularFireAuth } from '@angular/fire/compat/auth';
import { Router } from '@angular/router';
import { StorageService } from '../../services/storage.service';
import { ApiService } from '../../services/api.service';
import { ParkingModel } from '../../models/parking.model';
import { OwnerModel } from '../../models/owner.model';
import { ChartData, ChartOptions } from 'chart.js';

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {

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

  constructor(
    private afAuth: AngularFireAuth,
    private router: Router,
    private storageService: StorageService,
    private api: ApiService
  ) { }

  ngOnInit(): void {
    this.parkings = this.storageService.SessionGetStorage("parkings");
    this.owners = this.storageService.SessionGetStorage("owners");

    this.translateOwnerUIDToName();
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

  logout(): void {
    this.afAuth.signOut().then(() => {
      this.storageService.isLoggedNext(false);
      sessionStorage.clear();
      localStorage.clear();
      this.router.navigate(['/']);
    });
  }

  exportCSV(): void {
    // Example data to export (you can modify this to be the data you want to export)
    const parkingData = this.parkings.map(parking => ({
      Name: parking.name,
      Address: parking.address,
      Owner: parking.owner,
      Spots: parking.spots!.length,
      FilledSpots: parking.spots!.filter(spot => spot.filled).length,
      EmptySpots: parking.spots!.length - parking.spots!.filter(spot => spot.filled).length
    }));
  
    // Define the CSV headers
    const headers = ['Name', 'Address', 'Owner', 'Total Spots', 'Filled Spots', 'Empty Spots'];
  
    // Convert the data into CSV format
    const csvRows = [];
    csvRows.push(headers.join(',')); // Add headers to CSV
  
    // Add each row of data
    for (const row of parkingData) {
      csvRows.push(Object.values(row).join(','));
    }
  
    // Create the CSV file content
    const csvContent = csvRows.join('\n');
  
    // Trigger download
    this.downloadCSV(csvContent);
  }
  
  downloadCSV(csvContent: string): void {
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    if (link.download !== undefined) { // Feature detection for browsers
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
