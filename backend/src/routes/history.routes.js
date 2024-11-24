import {Router} from 'express'
import { getHistories, getHistory, createHistory, updateHistory, deleteHistory } from '../controllers/history.controller.js'

const router = Router()

/**
 * When one of the histories endpoints is reached, these functions trigger the corresponding function
 */
router.get('/histories', getHistories)

router.get('/histories/:id', getHistory)

router.post('/histories', createHistory)

router.patch('/histories/:id', updateHistory)

router.delete('/histories/:id', deleteHistory)


export default router