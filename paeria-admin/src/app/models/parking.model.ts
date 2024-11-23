import { GeoPoint } from 'firebase/firestore';  // Import GeoPoint from Firestore

export class ParkingModel {
  id?: string;
  description?: string;
  maxSpots?: number;
  name?: string;
  owner?: string;
  address?: string;
  coordinates?: GeoPoint;  // Change coordinates to GeoPoint
  spots?: { filled: boolean, id: number, plate: string }[];
}
