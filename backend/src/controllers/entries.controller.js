import {pool} from '../db.js'

/**
 * Recovers the entries from the database
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns {JSON} JSON containg the recovered data
 */
export const getEntries = async (req, res) => {
    try {
        print('getEntries')
    } catch (error) {
        return res.status(500).json({
            message: 'Something went wrong while retrieving the allergies'
        })
    }
}

/**
 * Recovers a specific entry from the database
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns {JSON} JSON containg the recovered data
 */
export const getEntry = async (req, res) => {
    try {
        print(req.params.id)
    } catch (error) {
        return res.status(500).json({
            message: 'Something went wrong while retrieving the allergy'
        })
    }
}

/**
 * Creates a new entry
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns {JSON} JSON containg the newly created data
 */
export const createEntry = async (req, res) => {
    try {
        print(req.body)
    } catch (error) {
        return res.status(500).json({
            message: 'Something went wrong while creating the entry'
        })
    }
}

/**
 * Deletes a specific entry
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns {CodecState} Code confirming a succsesful operation
 */
export const deleteEntry = async (req, res) => {
    try {
        /*
        const [result] = await pool.query('DELETE FROM entries WHERE id = ?', [req.params.id])
        if(result.affectedRows <= 0) return res.status(404).json({
            message: 'Allergy not found'
        })
        */
        res.sendStatus(204)
    } catch (error) {
        return res.status(500).json({
            message: 'Cannot delete the entry because it is being used'
        })
    }
}

/**
 * Updates an existing entry
 * @async
 * @param {Request} req 
 * @param {Response} res 
 * @returns {JSON} Json containing the new information
 */
export const updateEntry = async (req, res) => {
    try {
        print(req.body)
    } catch (error) {
        return res.status(500).json({
            message: 'Something went wrong while updating the entry'
        })
    }
}