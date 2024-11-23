import firebase from '../firebase.js';
import Owner from '../models/owner.model.js';
import {
  getFirestore,
  collection,
  getDocs,
} from 'firebase/firestore';

const db = getFirestore(firebase);

export const getOwners = async (req, res) => {
    try {
        const owners = await getDocs(collection(db, 'Owners'));
        const ownersArray = [];

        if (owners.empty) {
            res.status(400).send('No Owner found');
        } else {
            owners.forEach((doc) => {
            const owner = new Owner(
                doc.id,
                doc.data().name,
            );
            ownersArray.push(owner);
        });
            res.status(200).send(ownersArray);
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

