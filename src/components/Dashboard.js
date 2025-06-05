// src/components/Dashboard.js
import React from 'react';
import AdminDashboard from './AdminDashboard';
import AgencyDashboard from './AgencyDashboard';
import AddAgencyForm from './forms/AddAgencyForm'; // Importez le formulaire d'ajout d'agence

const Dashboard = ({ userRole, currentAgencyId, agenciesData, routesData, onLogout, onShowAddAgencyForm, showAddAgencyForm, onAddAgencySubmit, onCloseAddAgencyForm, handleAddTrip, showMessage }) => {
    return (
        <div className="bg-white p-6 md:p-8 rounded-xl shadow-2xl mt-12 w-full">
            <div className="flex flex-col sm:flex-row justify-between items-center mb-6">
                <h2 className="text-xl sm:text-3xl font-semibold text-emerald-700 mb-4 sm:mb-0">
                    Tableau de bord {userRole === 'admin' ? 'Administrateur' : `Agence: ${agenciesData.find(a => a.id === currentAgencyId)?.name}`}
                </h2>
                <button
                    onClick={onLogout}
                    className="bg-red-600 hover:bg-red-700 text-white font-semibold py-2 px-4 rounded-lg transition duration-150 w-full sm:w-auto"
                >
                    Déconnexion
                </button>
            </div>

            {userRole === 'admin' && (
                <AdminDashboard
                    agenciesData={agenciesData}
                    routesData={routesData}
                    onShowAddAgencyForm={onShowAddAgencyForm}
                    showAddAgencyForm={showAddAgencyForm}
                    onAddAgencySubmit={onAddAgencySubmit}
                    onCloseAddAgencyForm={onCloseAddAgencyForm}
                />
            )}
            {userRole === 'agency' && (
                <AgencyDashboard
                    currentAgencyId={currentAgencyId}
                    agenciesData={agenciesData}
                    routesData={routesData}
                    handleAddTrip={handleAddTrip}
                    showMessage={showMessage}
                />
            )}
        </div>
    );
};

export default Dashboard;
