import {Router} from 'express'
import { getHistory, getHistoryById, createHistory, updateHistory, deleteHistory } from '../controllers/history.controller.js'

const router = Router()


router.get('/history', getHistory)

router.get('/history/:id', getHistoryById)

router.post('/history', createHistory)

router.patch('/history/:id', updateHistory)

router.delete('/history/:id', deleteHistory)


export default router