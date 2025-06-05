// src/components/SearchSection.js
import React, { useState, useEffect } from 'react';
import { cities } from '../data/cities'; // Importation des villes

const SearchSection = ({ onSearch }) => {
    const [departureCity, setDepartureCity] = useState('Yaoundé');
    const [arrivalCity, setArrivalCity] = useState('Douala');
    const [travelDate, setTravelDate] = useState('');

    useEffect(() => {
        const today = new Date().toISOString().split('T')[0];
        setTravelDate(today);
    }, []);

    const handleSubmit = (e) => {
        e.preventDefault();
        onSearch(departureCity, arrivalCity, travelDate);
    };

    return (
        <section id="search-section" className="bg-white p-6 md:p-8 rounded-xl shadow-2xl mb-12">
            <h2 className="text-3xl font-semibold text-emerald-700 mb-6">Trouvez votre prochain voyage</h2>
            <p className="text-stone-600 mb-6">Entrez vos informations de voyage pour découvrir les options disponibles et réservez votre billet en toute simplicité.</p>
            <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
                <div>
                    <label htmlFor="departure-city" className="block text-sm font-medium text-stone-700 mb-1">Ville de départ</label>
                    <select
                        id="departure-city"
                        className="w-full p-3 border border-stone-300 rounded-lg shadow-sm focus:ring-emerald-500 focus:border-emerald-500"
                        value={departureCity}
                        onChange={(e) => setDepartureCity(e.target.value)}
                    >
                        {cities.map(city => <option key={city} value={city}>{city}</option>)}
                    </select>
                </div>
                <div>
                    <label htmlFor="arrival-city" className="block text-sm font-medium text-stone-700 mb-1">Ville d'arrivée</label>
                    <select
                        id="arrival-city"
                        className="w-full p-3 border border-stone-300 rounded-lg shadow-sm focus:ring-emerald-500 focus:border-emerald-500"
                        value={arrivalCity}
                        onChange={(e) => setArrivalCity(e.target.value)}
                    >
                        {cities.map(city => <option key={city} value={city}>{city}</option>)}
                    </select>
                </div>
                <div>
                    <label htmlFor="travel-date" className="block text-sm font-medium text-stone-700 mb-1">Date de voyage</label>
                    <input
                        type="date"
                        id="travel-date"
                        className="w-full p-3 border border-stone-300 rounded-lg shadow-sm focus:ring-emerald-500 focus:border-emerald-500"
                        value={travelDate}
                        onChange={(e) => setTravelDate(e.target.value)}
                        min={new Date().toISOString().split('T')[0]}
                        required
                    />
                </div>
                <div className="md:col-span-3">
                    <button type="submit" className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-3 px-6 rounded-lg shadow-md transition duration-150 ease-in-out">
                        Rechercher les voyages
                    </button>
                </div>
            </form>
        </section>
    );
};

export default SearchSection;
