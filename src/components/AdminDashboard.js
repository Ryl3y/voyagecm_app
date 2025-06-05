// src/components/AdminDashboard.js
import React from 'react';
import AddAgencyForm from './forms/AddAgencyForm'; // Importation du formulaire d'ajout d'agence

const AdminDashboard = ({ agenciesData, routesData, onShowAddAgencyForm, showAddAgencyForm, onAddAgencySubmit, onCloseAddAgencyForm }) => {
    const totalRoutes = routesData.length;
    const totalAgencies = agenciesData.length;
    const totalAvailableSeats = routesData.reduce((sum, route) => sum + route.availableSeats, 0);

    return (
        <div>
            <h3 className="text-2xl font-semibold text-stone-700 mb-4">Vue d'ensemble</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <div className="bg-emerald-50 p-4 rounded-lg shadow">
                    <p className="text-stone-600">Total Trajets:</p>
                    <p className="text-3xl font-bold text-emerald-800">{totalRoutes}</p>
                </div>
                <div className="bg-emerald-50 p-4 rounded-lg shadow">
                    <p className="text-stone-600">Total Agences:</p>
                    <p className="text-3xl font-bold text-emerald-800">{totalAgencies}</p>
                </div>
                <div className="bg-emerald-50 p-4 rounded-lg shadow">
                    <p className="text-stone-600">Sièges disponibles:</p>
                    <p className="text-3xl font-bold text-emerald-800">{totalAvailableSeats}</p>
                </div>
            </div>

            <div className="flex flex-col sm:flex-row justify-between items-center mb-4">
                <h3 className="text-xl sm:text-2xl font-semibold text-stone-700 mb-4 sm:mb-0">Toutes les réservations (Trajets)</h3>
                <button
                    onClick={onShowAddAgencyForm}
                    className="bg-green-600 hover:bg-green-700 text-white font-semibold py-2 px-4 rounded-lg transition duration-150 w-full sm:w-auto"
                >
                    Ajouter une nouvelle agence
                </button>
            </div>

            {showAddAgencyForm && (
                <AddAgencyForm onSubmit={onAddAgencySubmit} onClose={onCloseAddAgencyForm} />
            )}

            <div className="overflow-x-auto">
                <table className="min-w-full bg-white rounded-lg shadow overflow-hidden">
                    <thead className="bg-emerald-100">
                        <tr>
                            <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">ID Trajet</th>
                            <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Agence</th>
                            <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Départ</th>
                            <th className="py-3 px-4 text-left text-sm font-semibold tex…th" className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Heure Départ</th>
                            <th  className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Prix</th>
                            <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Sièges Dispo.</th>
                            <th className="py-3 px-4 text-left text-sm font-semibold text-emerald-700">Classe</th>
                        </tr>
                    </thead>
                    <tbody>
                        {routesData.map(route => (
                            <tr key={route.id} className="border-b border-stone-200 last:border-b-0 hover:bg-stone-50">
                                <td className="py-3 px-4 text-sm text-stone-700">{route.id}</td>
                                <td className="py-3 px-4 text-sm text-stone-700">{agenciesData.find(a => a.id === route.agencyId)?.name}</td>
                                <td className="py-3 px-4 text-sm text-stone-700">{route.departureTime}</td>
                                <td className="py-3 px-4 text-sm text-stone-700">{route.price.toLocaleString('fr-CM')} XAF</td>
                                <td className="py-3 px-4 text-sm text-stone-700">{route.availableSeats}</td>
                                <td className="py-3 px-4 text-sm text-stone-700">{route.class}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    );
};

export default AdminDashboard;