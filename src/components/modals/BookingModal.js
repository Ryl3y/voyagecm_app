// src/components/modals/BookingModal.js
import React, { useState } from 'react';
import Modal from './Modal';

const BookingModal = ({ show, onClose, selectedTrip, agenciesData, onConfirmBooking, showMessage }) => {
    const [passengerName, setPassengerName] = useState('');
    const [passengerCni, setPassengerCni] = useState('');
    const [passengerPhone, setPassengerPhone] = useState('');
    const [paymentMethod, setPaymentMethod] = useState('mtn');
    const [selectedSeat, setSelectedSeat] = useState(null);

    const agency = selectedTrip ? agenciesData.find(a => a.id === selectedTrip.agencyId) : null;
    const totalSeats = selectedTrip ? selectedTrip.seats.length : 0;
    const availableSeats = selectedTrip ? selectedTrip.seats.map((isOccupied, index) => !isOccupied ? index + 1 : null).filter(s => s !== null) : [];

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!selectedSeat) {
            showMessage("Siège manquant", "Veuillez sélectionner un numéro de siège.");
            return;
        }
        onConfirmBooking({ passengerName, passengerCni, passengerPhone, paymentMethod }, selectedSeat);
        // Réinitialiser le formulaire après la soumission réussie
        setPassengerName('');
        setPassengerCni('');
        setPassengerPhone('');
        setPaymentMethod('mtn');
        setSelectedSeat(null);
    };

    return (
        <Modal show={show} onClose={onClose}>
            <h3 className="text-2xl font-semibold text-emerald-700 mb-4">Réserver votre billet</h3>
            {selectedTrip && agency && (
                <div id="booking-trip-summary" className="mb-4 p-3 bg-emerald-50 rounded-lg border border-emerald-200">
                    <p><strong>Agence:</strong> {agency.name}</p>
                    <p><strong>Trajet:</strong> {selectedTrip.departureCity} ➡️ {selectedTrip.arrivalCity}</p>
                    <p><strong>Départ:</strong> {selectedTrip.departureTime} | <strong>Arrivée:</strong> {selectedTrip.arrivalTime}</p>
                    <p><strong>Classe:</strong> {selectedTrip.class} {selectedTrip.class === "VIP" && "(Climatisé)"} {selectedTrip.class === "Confort" && "(Toilettes)"} {selectedTrip.class === "Zoom" && "(50 places)"}</p>
                    <p><strong>Prix:</strong> {selectedTrip.price.toLocaleString('fr-CM')} XAF</p>
                    <p><strong>Sièges disponibles:</strong> {selectedTrip.availableSeats}</p>
                </div>
            )}
            <form onSubmit={handleSubmit}>
                <div className="mb-3">
                    <label htmlFor="passenger-name" className="block text-sm font-medium text-stone-700">Nom complet</label>
                    <input type="text" id="passenger-name" className="mt-1 block w-full p-2 border border-stone-300 rounded-md shadow-sm" value={passengerName} onChange={(e) => setPassengerName(e.target.value)} required />
                </div>
                <div className="mb-3">
                    <label htmlFor="passenger-cni" className="block text-sm font-medium text-stone-700">Numéro de CNI</label>
                    <input type="text" id="passenger-cni" className="mt-1 block w-full p-2 border border-stone-300 rounded-md shadow-sm" value={passengerCni} onChange={(e) => setPassengerCni(e.target.value)} required />
                </div>
                <div className="mb-3">
                    <label htmlFor="passenger-phone" className="block text-sm font-medium text-stone-700">Numéro de téléphone</label>
                    <input type="tel" id="passenger-phone" className="mt-1 block w-full p-2 border border-stone-300 rounded-md shadow-sm" value={passengerPhone} onChange={(e) => setPassengerPhone(e.target.value)} required />
                </div>

                {/* Sélection du siège */}
                <div className="mb-4">
                    <label className="block text-sm font-medium text-stone-700 mb-2">
                        Sélectionnez votre siège ({selectedTrip && selectedTrip.class === "Zoom" ? "50 places" : "70 places"})
                    </label>
                    <div className="seat-grid">
                        {selectedTrip && selectedTrip.seats.map((isOccupied, index) => (
                            <div
                                key={index + 1}
                                className={`seat ${isOccupied ? 'occupied' : 'available'} ${selectedSeat === (index + 1) ? 'selected' : ''}`}
                                onClick={() => !isOccupied && setSelectedSeat(index + 1)}
                                title={isOccupied ? 'Occupé' : 'Disponible'}
                            >
                                {index + 1}
                            </div>
                        ))}
                    </div>
                    {selectedSeat && (
                        <p className="mt-2 text-sm text-stone-600">Siège sélectionné : <span className="font-semibold">{selectedSeat}</span></p>
                    )}
                    {selectedTrip && selectedTrip.availableSeats === 0 && (
                        <p className="mt-2 text-sm text-red-500">Désolé, il n'y a plus de sièges disponibles pour ce trajet.</p>
                    )}
                </div>

                <div className="mb-4">
                    <p className="block text-sm font-medium text-stone-700 mb-1">Méthode de paiement</p>
                    <div className="flex items-center space-x-4">
                        <label className="flex items-center p-2 border border-stone-300 rounded-md hover:bg-stone-50 cursor-pointer">
                            <input type="radio" name="payment-method" value="mtn" className="form-radio h-4 w-4 text-emerald-600" checked={paymentMethod === 'mtn'} onChange={(e) => setPaymentMethod(e.target.value)} />
                            <img src="https://placehold.co/60x30/FFCC00/000000?text=MTN" alt="MTN Mobile Money" className="ml-2 h-6" />
                        </label>
                        <label className="flex items-center p-2 border border-stone-300 rounded-md hover:bg-stone-50 cursor-pointer">
                            <input type="radio" name="payment-method" value="orange" className="form-radio h-4 w-4 text-emerald-600" checked={paymentMethod === 'orange'} onChange={(e) => setPaymentMethod(e.target.value)} />
                            <img src="https://placehold.co/80x30/FF6600/FFFFFF?text=Orange" alt="Orange Money" className="ml-2 h-6" />
                        </label>
                    </div>
                </div>
                <button type="submit" className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-2 px-4 rounded-lg">
                    Confirmer la réservation (Simulation)
                </button>
            </form>
        </Modal>
    );
};

export default BookingModal;
