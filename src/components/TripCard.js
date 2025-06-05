// src/components/TripCard.js
import React from 'react';

const TripCard = ({ route, agency, onBookTrip }) => (
    <div className="bg-white p-5 rounded-xl shadow-lg flex flex-col justify-between">
        <div>
            {/* Image du bus de l'agence */}
            {agency.imageUrl && (
                <img src={agency.imageUrl} alt={`Bus de ${agency.name}`} className="w-full h-auto rounded-md mb-3 object-cover" onError={(e) => { e.target.onerror = null; e.target.src="https://placehold.co/150x80/E2E8F0/64748B?text=Image+non+disponible"; }} />
            )}
            <div className="flex items-center mb-3">
                <span className="text-2xl mr-2">{agency.logo}</span>
                <h4 className="text-xl font-semibold text-emerald-700">
                    <span>{agency.name}</span>
                    {agency.verified && (
                        <span className="text-green-500 text-sm ml-1">✅ Vérifié</span>
                    )}
                </h4>
            </div>
            <p className="text-stone-600 mb-1"><span className="font-medium">Trajet:</span> {route.departureCity} ➡️ {route.arrivalCity}</p>
            <p className="text-stone-600 mb-1"><span className="font-medium">Départ:</span> {route.departureTime} | <span className="font-medium">Arrivée:</span> {route.arrivalTime}</p>
            <p className="text-stone-600 mb-1"><span className="font-medium">Classe:</span> {route.class} {route.class === "VIP" && "(Climatisé)"} {route.class === "Confort" && "(Toilettes)"} {route.class === "Zoom" && "(50 places)"}</p>
            <p className="text-stone-600 mb-3"><span className="font-medium">Services:</span> {agency.services.join(', ')}</p>
            <p className="text-2xl font-bold text-emerald-600 mb-3">{route.price.toLocaleString('fr-CM')} XAF</p>
            <p className="text-stone-600 mb-3"><span className="font-medium">Sièges disponibles:</span> {route.availableSeats}</p>
        </div>
        <button onClick={() => onBookTrip(route.id)} className="w-full mt-4 bg-emerald-500 hover:bg-emerald-600 text-white font-semibold py-2 px-4 rounded-lg transition duration-150">
            Réserver ce trajet
        </button>
    </div>
);

export default TripCard;
