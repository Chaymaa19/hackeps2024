import {Router} from 'express'
import { getOwners} from '../controllers/owner.controller.js'

const router = Router()


router.get('/owners', getOwners)


export default router