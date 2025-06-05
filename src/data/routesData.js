// src/data/routesData.js
import { generateSeats } from '../utils/generateSeats';

const routesData = [
    // Centre - Littoral
    { id: "R001", departureCity: "Yaoundé", arrivalCity: "Douala", agencyId: 1, departureTime: "08:00", arrivalTime: "12:00", price: 6500, class: "VIP", availableSeats: 70, seats: generateSeats(70) },
    { id: "R002", departureCity: "Yaoundé", arrivalCity: "Douala", agencyId: 1, departureTime: "10:00", arrivalTime: "14:00", price: 6000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R003", departureCity: "Yaoundé", arrivalCity: "Douala", agencyId: 2, departureTime: "09:00", arrivalTime: "13:00", price: 6200, class: "Confort", availableSeats: 70, seats: generateSeats(70) },
    // Littoral - Centre
    { id: "R004", departureCity: "Douala", arrivalCity: "Yaoundé", agencyId: 1, departureTime: "14:00", arrivalTime: "18:00", price: 6500, class: "VIP", availableSeats: 70, seats: generateSeats(70) },
    { id: "R005", departureCity: "Douala", arrivalCity: "Yaoundé", agencyId: 2, departureTime: "15:00", arrivalTime: "19:00", price: 6000, class: "Confort", availableSeats: 70, seats: generateSeats(70) },
    // Centre - Ouest
    { id: "R006", departureCity: "Yaoundé", arrivalCity: "Bafoussam", agencyId: 3, departureTime: "07:00", arrivalTime: "11:30", price: 5000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R007", departureCity: "Bafoussam", arrivalCity: "Yaoundé", agencyId: 3, departureTime: "13:00", arrivalTime: "17:30", price: 5000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R008", departureCity: "Yaoundé", arrivalCity: "Dschang", agencyId: 3, departureTime: "09:00", arrivalTime: "14:00", price: 5500, class: "Confort", availableSeats: 70, seats: generateSeats(70) },
    // Ouest - Littoral
    { id: "R009", departureCity: "Bafoussam", arrivalCity: "Douala", agencyId: 5, departureTime: "09:30", arrivalTime: "14:00", price: 5500, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R010", departureCity: "Dschang", arrivalCity: "Douala", agencyId: 5, departureTime: "10:00", arrivalTime: "15:00", price: 5800, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    // Centre - Sud
    { id: "R011", departureCity: "Yaoundé", arrivalCity: "Kribi", agencyId: 4, departureTime: "11:00", arrivalTime: "15:00", price: 7000, class: "Confort", availableSeats: 70, seats: generateSeats(70) },
    { id: "R012", departureCity: "Kribi", arrivalCity: "Yaoundé", agencyId: 4, departureTime: "16:00", arrivalTime: "20:00", price: 7000, class: "Confort", availableSeats: 70, seats: generateSeats(70) },
    { id: "R013", departureCity: "Yaoundé", arrivalCity: "Ebolowa", agencyId: 10, departureTime: "07:30", arrivalTime: "10:30", price: 4000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    // Littoral - Sud-Ouest
    { id: "R014", departureCity: "Douala", arrivalCity: "Buea", agencyId: 7, departureTime: "06:00", arrivalTime: "08:30", price: 3500, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R015", departureCity: "Douala", arrivalCity: "Limbe", agencyId: 7, departureTime: "07:00", arrivalTime: "09:00", price: 3000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    // Nord-Ouest - Ouest
    { id: "R016", departureCity: "Bamenda", arrivalCity: "Bafoussam", agencyId: 3, departureTime: "09:00", arrivalTime: "12:00", price: 4500, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    // Adamaoua - Nord
    { id: "R017", departureCity: "Ngaoundéré", arrivalCity: "Garoua", agencyId: 8, departureTime: "08:00", arrivalTime: "13:00", price: 8000, class: "Confort", availableSeats: 70, seats: generateSeats(70) },
    // Nord - Extrême-Nord
    { id: "R018", departureCity: "Garoua", arrivalCity: "Maroua", agencyId: 6, departureTime: "14:00", arrivalTime: "17:00", price: 5000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    // Centre - Est
    { id: "R019", departureCity: "Yaoundé", arrivalCity: "Bertoua", agencyId: 9, departureTime: "07:00", arrivalTime: "12:00", price: 6000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R020", departureCity: "Bertoua", arrivalCity: "Yaoundé", agencyId: 9, departureTime: "13:00", arrivalTime: "18:00", price: 6000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    // Autres trajets inter-régionaux
    { id: "R021", departureCity: "Douala", arrivalCity: "Bamenda", agencyId: 3, departureTime: "06:30", arrivalTime: "13:00", price: 8000, class: "VIP", availableSeats: 70, seats: generateSeats(70) },
    { id: "R022", departureCity: "Bamenda", arrivalCity: "Douala", agencyId: 3, departureTime: "07:00", arrivalTime: "13:30", price: 8000, class: "VIP", availableSeats: 70, seats: generateSeats(70) },
    { id: "R023", departureCity: "Yaoundé", arrivalCity: "Ngaoundéré", agencyId: 8, departureTime: "18:00", arrivalTime: "06:00", price: 12000, class: "VIP", availableSeats: 70, seats: generateSeats(70) },
    { id: "R024", departureCity: "Ngaoundéré", arrivalCity: "Yaoundé", agencyId: 8, departureTime: "18:30", arrivalTime: "06:30", price: 12000, class: "VIP", availableSeats: 70, seats: generateSeats(70) },
    { id: "R025", departureCity: "Maroua", arrivalCity: "Garoua", agencyId: 6, departureTime: "09:00", arrivalTime: "12:00", price: 5000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R026", departureCity: "Garoua", arrivalCity: "Maroua", agencyId: 6, departureTime: "10:00", arrivalTime: "13:00", price: 5000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R027", departureCity: "Kumba", arrivalCity: "Douala", agencyId: 7, departureTime: "08:00", arrivalTime: "11:00", price: 4000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R028", departureCity: "Douala", arrivalCity: "Kumba", agencyId: 7, departureTime: "13:00", arrivalTime: "16:00", price: 4000, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R029", departureCity: "Bafoussam", arrivalCity: "Foumban", agencyId: 3, departureTime: "10:00", arrivalTime: "11:30", price: 2500, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R030", departureCity: "Foumban", arrivalCity: "Bafoussam", agencyId: 3, departureTime: "14:00", arrivalTime: "15:30", price: 2500, class: "Classique", availableSeats: 70, seats: generateSeats(70) },
    { id: "R031", departureCity: "Yaoundé", arrivalCity: "Douala", agencyId: 1, departureTime: "16:00", arrivalTime: "20:00", price: 7500, class: "Zoom", availableSeats: 50, seats: generateSeats(50) }, // Exemple de trajet Zoom
];

export default routesData;
