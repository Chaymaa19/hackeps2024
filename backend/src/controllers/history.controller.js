import firebase from '../firebase.js';
import History from '../models/history.model.js';
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

export const createHistory = async (req, res) => {
    try {
        const data = req.body;
        await addDoc(collection(db, 'history'), data);
        res.status(200).send('history created successfully');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

export const getHistories = async (req, res) => {
    try {
        const histories = await getDocs(collection(db, 'history'));
        const historiesArray = [];

        if (histories.empty) {
            res.status(400).send('No History found');
        } else {
            histories.forEach((doc) => {
            const history = new History(
                doc.id,
                doc.data().idParking,
                doc.data().date,
                doc.data().numSpots,
            );
            historiesArray.push(history);
        });
            res.status(200).send(historiesArray);
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

export const getHistory = async (req, res) => {
    try {
        const id = req.params.id;
        const history = await getDoc(doc(db, 'history', id));

        if (!history.exists()) {
            res.status(400).send('No History found');
        } else {
            res.status(200).send(history.data());
        }
    } catch (error) {
        res.status(400).send(error.message);
    }
}

export const updateHistory = async (req, res) => {
    try {
        const id = req.params.id;
        const data = req.body;
        await updateDoc(doc(db, 'history', id), data);
        res.status(200).send('History updated successfully');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

export const deleteHistory = async (req, res) => {
    try {
        const id = req.params.id;
        await deleteDoc(doc(db, 'history', id));
        res.status(200).send('History deleted successfully');
    } catch (error) {
        res.status(400).send(error.message);
    }
}

