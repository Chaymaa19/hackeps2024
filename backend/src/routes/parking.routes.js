import {Router} from 'express'
import { getParkings, getParking, getParkingByOwner, createParking, updateParking, toggleSpotStatus, getAvailableSpot, deleteParking } from '../controllers/parking.controller.js'


const router = Router()

/**
 * When one of the parkings endpoints is reached, these functions trigger the corresponding function
 */
router.get('/parkings', getParkings)

router.get('/parkings/:id', getParking)

// get parking by owner
router.get('/parkings/owner/:owner', getParkingByOwner)

router.get('/parkings/:id/available-spots', getAvailableSpot);

router.post('/parkings', createParking)

router.patch('/parkings/:id', updateParking)

router.patch('/parkings/:id/spot/:spotId', toggleSpotStatus);

router.delete('/parkings/:id', deleteParking)


export default router