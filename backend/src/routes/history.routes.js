import {Router} from 'express'
import { getHistories, getHistory, createHistory, updateHistory, deleteHistory } from '../controllers/history.controller.js'

const router = Router()


router.get('/histories', getHistories)

router.get('/histories/:id', getHistory)

router.post('/histories', createHistory)

router.patch('/histories/:id', updateHistory)

router.delete('/histories/:id', deleteHistory)


export default router