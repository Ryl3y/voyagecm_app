// src/components/forms/AddTripForm.js
import React, { useState } from 'react';
import { cities } from '../../data/cities'; // Importation des villes

const AddTripForm = ({ onSubmit, onClose, showMessage }) => { // showMessage est passé en prop
    const [departureCity, setDepartureCity] = useState('');
    const [arrivalCity, setArrivalCity] = useState('');
    const [departureTime, setDepartureTime] = useState('');
    const [arrivalTime, setArrivalTime] = useState('');
    const [price, setPrice] = useState('');
    const [tripClass, setTripClass] = useState('Classique'); // Défaut à Classique

    const handleSubmit = (e) => {
        e.preventDefault();
        if (departureCity === arrivalCity) {
            showMessage("Erreur de sélection", "La ville de départ et la ville d'arrivée ne peuvent pas être identiques.");
            return;
        }
        onSubmit({
            departureCity,
            arrivalCity,
            departureTime,
            arrivalTime,
            price,
            class: tripClass,
        });
    };

    return (
        <div className="bg-white p-6 rounded-xl shadow-md mb-8 w-full">
            <h3 className="text-2xl font-semibold text-emerald-700 mb-4">Ajouter un nouveau trajet</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                    <label htmlFor="trip-departure-city" className="block text-sm font-medium text-stone-700 mb-1">Ville de départ</label>
                    <select
                        id="trip-departure-city"
                        className="w-full p-2 border border-stone-300 rounded-md shadow-sm"
                        value={departureCity}
                        onChange={(e) => setDepartureCity(e.target.value)}
                        required
                    >
                        <option value="">Sélectionner une ville</option>
                        {cities.map(city => <option key={city} value={city}>{city}</option>)}
                    </select>
                </div>
                <div>
                    <label htmlFor="trip-arrival-city" className="block text-sm font-medium text-stone-700 mb-1">Ville d'arrivée</label>
                    <select
                        id="trip-arrival-city"
                        className="w-full p-2 border border-stone-300 rounded-md shadow-sm"
                        value={arrivalCity}
                        onChange={(e) => setArrivalCity(e.target.value)}
                        required
                    >
                        <option value="">Sélectionner une ville</option>
                        {cities.map(city => <option key={city} value={city}>{city}</option>)}
                    </select>
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label htmlFor="trip-departure-time" className="block text-sm font-medium text-stone-700 mb-1">Heure de départ</label>
                        <input type="time" id="trip-departure-time" className="w-full p-2 border border-stone-300 rounded-md shadow-sm" value={departureTime} onChange={(e) => setDepartureTime(e.target.value)} required />
                    </div>
                    <div>
                        <label htmlFor="trip-arrival-time" className="block text-sm font-medium text-stone-700 mb-1">Heure d'arrivée (estimée)</label>
                        <input type="time" id="trip-arrival-time" className="w-full p-2 border border-stone-300 rounded-md shadow-sm" value={arrivalTime} onChange={(e) => setArrivalTime(e.target.value)} required />
                    </div>
                </div>
                <div>
                    <label htmlFor="trip-price" className="block text-sm font-medium text-stone-700 mb-1">Prix (XAF)</label>
                    <input type="number" id="trip-price" className="w-full p-2 border border-stone-300 rounded-md shadow-sm" value={price} onChange={(e) => setPrice(e.target.value)} required min="0" />
                </div>
                <div>
                    <label htmlFor="trip-class" className="block text-sm font-medium text-stone-700 mb-1">Classe</label>
                    <select
                        id="trip-class"
                        className="w-full p-2 border border-stone-300 rounded-md shadow-sm"
                        value={tripClass}
                        onChange={(e) => setTripClass(e.target.value)}
                        required
                    >
                        <option value="Classique">Classique</option>
                        <option value="Confort">Confort (avec toilettes)</option>
                        <option value="VIP">VIP (avec climatiseur)</option>
                        <option value="Zoom">Zoom (50 places)</option>
                    </select>
                </div>
                <div className="flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-4 mt-4">
                    <button type="button" onClick={onClose} className="bg-stone-300 hover:bg-stone-400 text-stone-800 font-semibold py-2 px-4 rounded-lg transition duration-150 w-full sm:w-auto">
                        Annuler
                    </button>
                    <button type="submit" className="bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-2 px-4 rounded-lg transition duration-150 w-full sm:w-auto">
                        Ajouter le trajet
                    </button>
                </div>
            </form>
        </div>
    );
};

export default AddTripForm;
