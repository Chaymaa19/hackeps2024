import firebase from '../firebase.js';
import Parking from '../models/parking.model.js';
import {
  getFirestore,
  collection,
  doc,
  addDoc,
  getDoc, 
  getDocs,
  updateDoc,
  deleteDoc,
} from 'firebase/firestore';

const db = getFirestore(firebase);

/**
 * Creates a new parking entry
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns status message
 */
export const createParking = async (req, res) => {
    try {
        const data = req.body;
        await addDoc(collection(db, 'parkings'), data);
        res.status(200).send('parking created successfully');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

/**
 * Recovers the parkings from the database
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns status message
 */
export const getParkings = async (req, res) => {
    try {
        const parkings = await getDocs(collection(db, 'parkings'));
        const parkingsArray = [];

        if (parkings.empty) {
            res.status(400).send('No Parking found');
        } else {
            parkings.forEach((doc) => {
            const parking = new Parking(
                doc.id,
                doc.data().name,
                doc.data().description,
                doc.data().address,
                doc.data().coordinates,
                doc.data().owner,
                doc.data().maxSpots,
                doc.data().spots,
            );
            parkingsArray.push(parking);
        });
            res.status(200).send(parkingsArray);
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

/**
 * Recovers a specific parking from the database
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns status message
 */
export const getParking = async (req, res) => {
    try {
        const id = req.params.id;
        const parking = doc(db, 'parkings', id);
        const data = await getDoc(parking);
        if (data.exists()) {
            res.status(200).send(data.data());
        } else {
            res.status(404).send('parking not found');
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

/**
 * Gets all parkings by owner
 * @param {Request} req 
 * @param {Response} res 
 * @returns status message
 */
export const getParkingByOwner = async (req, res) => {
    try {
        const owner = req.params.owner;
        const parkings = await getDocs(collection(db, 'parkings'));
        const parkingsArray = [];

        if (parkings.empty) {
            res.status(400).send('No Parking found');
        } else {
            parkings.forEach((doc) => {
            if(doc.data().owner === owner){
                const parking = new Parking(
                    doc.id,
                    doc.data().name,
                    doc.data().description,
                    doc.data().address,
                    doc.data().coordinates,
                    doc.data().owner,
                    doc.data().maxSpots,
                    doc.data().spots,
                );
                parkingsArray.push(parking);
            }
        });
            res.status(200).send(parkingsArray);
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

/**
 * Updates an existing entry
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns status message
 */
export const updateParking = async (req, res) => {
    try {
        const id = req.params.id;
        const data = req.body;
        const parking = doc(db, 'parkings', id);
        await updateDoc(parking, data);
        res.status(200).send('parking updated successfully');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

/**
 * Deletes a specific entry
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns status message
 */
export const deleteParking = async (req, res) => {
    try {
        const id = req.params.id;
        await deleteDoc(doc(db, 'parkings', id));
        res.status(200).send('parking deleted successfully');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

/**
 * Changes the status of a parking spot
 * @param {*} req 
 * @param {*} res 
 * @returns status message
 */
export const toggleSpotStatus = async (req, res) => {
    try {
        const parkingId = req.params.id; // Parking document ID
        const spotId = parseInt(req.params.spotId); // Spot ID (parsed as integer)
      
        // Get the parking document
        const parkingRef = doc(db, 'parkings', parkingId);
        const parkingSnapshot = await getDoc(parkingRef);

        if (!parkingSnapshot.exists()) {
            return res.status(404).send('Parking not found');
        }

        // Retrieve current spots array
        const parkingData = parkingSnapshot.data();
        const spots = parkingData.spots;

        // Find the spot by its ID
        const spotIndex = spots.findIndex(spot => spot.id === spotId);
        if (spotIndex === -1) {
            return res.status(404).send('Spot not found');
        }

        // Toggle the filled status
        spots[spotIndex].filled = !spots[spotIndex].filled;

        // Update the document in Firestore
        await updateDoc(parkingRef, { spots });

        res.status(200).send({
            message: 'Spot status updated successfully',
            spot: spots[spotIndex]
        });
    } catch (error) {
        res.status(400).send(error.message);
    }
};

/**
 * Gets a randomly available parking spot
 * @param {*} req 
 * @param {*} res 
 * @returns status message
 */
export const getAvailableSpot = async (req, res) => {
    try {
      const parkingId = req.params.id;
  
      // Fetch the parking document
      const parkingRef = doc(db, 'parkings', parkingId);
      const parkingSnapshot = await getDoc(parkingRef);
  
      if (!parkingSnapshot.exists()) {
        return res.status(404).send('Parking not found');
      }
  
      // Extract spots array
      const parkingData = parkingSnapshot.data();
      const spots = parkingData.spots;
  
      // Filter unfilled spots
      const availableSpots = spots.filter(spot => !spot.filled);
  
      if (availableSpots.length === 0) {
        return res.status(404).send('No available spots found');
      }
  
      // Extract IDs of unfilled spots
      const availableSpotIds = availableSpots.map(spot => spot.id);
  
      // Randomly select one spot
      const randomSpotId =
        availableSpotIds[Math.floor(Math.random() * availableSpotIds.length)];
  
      res.status(200).send({
        availableSpotIds,
        selectedSpotId: randomSpotId,
      });
    } catch (error) {
      res.status(400).send(error.message);
    }
  };
  
  