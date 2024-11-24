/**
 * Model class for History object
 */
class History {
    constructor(id, idParking, timestamp, numSpots) {
        this.id = id;
        this.idParking = idParking;
        this.timestamp = timestamp;
        this.numSpots = numSpots;
    }
}

export default History;