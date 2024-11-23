import express from 'express'
import cors from 'cors'
import entryRoutes from './routes/entries.routes.js'

const app = express();
app.use(cors())
app.use(express.json()) 


//routes
app.use(entryRoutes) 

/**
 *Middleware for when routes were not found, returns a 404 state
 */
app.use((req, res, next) => {
  res.status(404).json({
    message: 'API endpoint not found'
  })
})

export default app;