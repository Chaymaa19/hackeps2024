import {Router} from 'express'
import { getEntries, getEntry, createEntry, updateEntry, deleteEntry } from '../controllers/entries.controller.js'


const router = Router()

/**
 * When one of the allergies endpoints is reached, these functions trigger the corresponding function
 */
router.get('/entries', getEntries)

router.get('/entries/:id', getEntry)

router.post('/entries', createEntry)

router.patch('/entries/:id', updateEntry)

router.delete('/entries/:id', deleteEntry)


export default router