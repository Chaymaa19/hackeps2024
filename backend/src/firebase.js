import { initializeApp } from 'firebase/app';
import config from './config.js';

//initialize firebase
const firebase = initializeApp(config.firebaseConfig);

export default firebase;