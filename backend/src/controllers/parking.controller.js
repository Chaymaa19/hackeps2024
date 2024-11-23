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
 * @returns {JSON} JSON containg the newly created data
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
 * Recovers the entries from the database
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns {JSON} JSON containg the recovered data
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
                doc.data().owner,
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
 * Recovers a specific entry from the database
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns {JSON} JSON containg the recovered data
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
                    doc.data().owner,
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
 * @returns {JSON} Json containing the new information
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
 * @returns {CodecState} Code confirming a succsesful operation
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