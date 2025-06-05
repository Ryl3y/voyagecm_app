// src/components/AgencyDashboard.js
import React, { useState } from 'react';
import AddTripForm from './forms/AddTripForm'; // Importation du formulaire d'ajout de trajet
import { cities } from '../data/cities'; // Importation des villes

const AgencyDashboard = ({ currentAgencyId, agenciesData, routesData, handleAddTrip, showMessage }) => {
    const agencyRoutes = routesData.filter(route => route.agencyId === currentAgencyId);
    const agencyName = agenciesData.find(a => a.id === currentAgencyId)?.name;
    const [showAddTripForm, setShowAddTripForm] = useState(false); // État pour le formulaire d'ajout de trajet

    const handleAddTripSubmit = (tripDetails) => {
        const newId = `R${Date.now().toString().slice(-6)}`; // Générer un ID unique
        const capacity = tripDetails.class === "Zoom" ? 50 : 70; // Capacité basée sur la classe
        const newTrip = {
            id: newId,
            agencyId: currentAgencyId,
            ...tripDetails,
            price: parseInt(tripDetails.price), // Convertir le prix en nombre
            availableSeats: capacity, // Initialiser les sièges disponibles à la capacité max
            seats: Array(capacity).fill(false), // Initialiser le tableau des sièges
        };
        handleAddTrip(newTrip);
        showMessage("Trajet ajouté !", `Le trajet de ${newTrip.departureCity} à ${newTrip.arrivalCity} (${newTrip.class}) a été ajouté.`);
        setShowAddTripForm(false); // Cacher le formulaire après l'ajout
    };

    return (
        <div>
            <h3 className="text-2xl font-semibold text-stone-700 mb-4">Vos Trajets ({agencyName})</h3>
            <div className="flex justify-end mb-4">
                <button
                    onClick={() => setShowAddTripForm(true)}
                    className="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded-lg transition duration-150 w-full sm:w-auto"
                >
                    Ajouter un nouveau trajet
                </button>
            </div>

            {showAddTripForm && (
                <AddTripForm
                    onSubmit={handleAddTripSubmit}
                    onClose={() => setShowAddTripForm(false)}
                    cities={cities}
                />
            )}

            {agencyRoutes.length > 0 ? (
                <div className="overflow-x-auto">
                    <table className="min-w-full bg-white rounded-lg shadow overflow-hidden">
                        <thead className="bg-emerald-100">
                            <tr>
                                <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">ID Trajet</th>
                                <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Départ</th>
                                <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Arrivée</th>
                                <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Heure Départ</th>
                                <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Prix</th>
                                <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Sièges Dispo.</th>
                                <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Classe</th>
                                <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            {agencyRoutes.map(route => (
                                <tr key={route.id} className="border-b border-stone-200 last:border-b-0 hover:bg-stone-50">
                                    <td className="py-3 px-4 text-sm text-stone-700">{route.id}</td>
                                    <td className="py-3 px-4 text-sm text-stone-700">{route.departureCity}</td>
                                    <td className="py-3 px-4 text-sm text-stone-700">{route.arrivalCity}</td>
                                    <td className="py-3 px-4 text-sm text-stone-700">{route.departureTime}</td>
                                    <td className="py-3 px-4 text-sm text-stone-700">{route.price.toLocaleString('fr-CM')} XAF</td>
                                    <td className="py-3 px-4 text-sm text-stone-700">{route.availableSeats}</td>
                                    <td className="py-3 px-4 text-sm text-stone-700">{route.class}</td>
                                    <td className="py-3 px-4 text-sm text-stone-700">
                                        <button className="bg-blue-500 hover:bg-blue-600 text-white text-xs px-3 py-1 rounded mr-2">Modifier</button>
                                        <button className="bg-red-500 hover:bg-red-600 text-white text-xs px-3 py-1 rounded">Supprimer</button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            ) : (
                <p className="text-stone-500">Aucun trajet trouvé pour cette agence. Cliquez sur "Ajouter un nouveau trajet" pour commencer.</p>
            )}
        </div>
    );
};

export default AgencyDashboard;
