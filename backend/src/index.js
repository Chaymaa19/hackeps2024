import express from 'express';
import cors from 'cors';

import config from './config.js';

// Import routes
import parkingRoutes from './routes/parking.routes.js';
import ownerRoutes from './routes/owner.routes.js';
import historyRoutes from './routes/history.routes.js';

// Create express app
const app = express();

// Use middlewares
app.use(cors());
app.use(express.json());

// Use routes
app.use(parkingRoutes);
app.use(ownerRoutes);
app.use(historyRoutes);

// Start the server
app.listen(config.port, () =>
  console.log(`Server is live @ ${config.hostUrl}`),
);