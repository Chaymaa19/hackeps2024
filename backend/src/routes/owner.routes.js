import {Router} from 'express'
import { getOwners} from '../controllers/owner.controller.js'

const router = Router()

/**
 * When one of the owners endpoints is reached, these functions trigger the corresponding function
 */
router.get('/owners', getOwners)


export default router