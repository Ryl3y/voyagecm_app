// src/components/AdminPanel.js
import React, { useState } from 'react';
import LoginPanel from './LoginPanel';
import Dashboard from './Dashboard';

const AdminPanel = ({
  agenciesData, setAgenciesData,
  routesData, setRoutesData,
  onBackToPublic,
  showMessage,
  handleAddTrip
}) => {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userRole, setUserRole] = useState(null); // 'admin' ou 'agency'
  const [currentAgencyId, setCurrentAgencyId] = useState(null);
  const [showAddAgencyForm, setShowAddAgencyForm] = useState(false); // Pour afficher le formulaire d'ajout

  const handleLogin = (username, password) => {
    // Simulation d'authentification
    if (username === 'admin' && password === 'admin123') {
      setIsLoggedIn(true);
      setUserRole('admin');
      setCurrentAgencyId(null);
      showMessage("Connexion réussie", "Bienvenue, Administrateur !");
    } else {
      const agency = agenciesData.find(
        a => a.username === username && a.password === password
      );
      if (agency) {
        setIsLoggedIn(true);
        setUserRole('agency');
        setCurrentAgencyId(agency.id);
        showMessage("Connexion réussie", `Bienvenue, Agence ${agency.name} !`);
      } else {
        showMessage("Erreur de connexion", "Nom d'utilisateur ou mot de passe incorrect.");
      }
    }
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setUserRole(null);
    setCurrentAgencyId(null);
    setShowAddAgencyForm(false);
    showMessage("Déconnexion", "Vous avez été déconnecté.");
  };

  const handleAddAgencySubmit = (newAgencyDetails) => {
    const newId = Math.max(...agenciesData.map(a => a.id)) + 1;
    const newUsername = `agency${newId}`;
    const newPassword = `pass${newId}`; // Mot de passe simple pour la simulation

    const newAgency = {
      id: newId,
      name: newAgencyDetails.name,
      logo: newAgencyDetails.logo,
      verified: newAgencyDetails.verified,
      services: newAgencyDetails.services.split(',').map(s => s.trim()),
      imageUrl: newAgencyDetails.imageUrl,
      username: newUsername,
      password: newPassword,
    };

    setAgenciesData(prevData => [...prevData, newAgency]);
    showMessage(
      "Agence ajoutée !",
      `L'agence "${newAgency.name}" a été ajoutée. Identifiants: Nom d'utilisateur: ${newUsername}, Mot de passe: ${newPassword}`
    );
    setShowAddAgencyForm(false); // Cacher le formulaire après l'ajout
  };

  return (
    <div className="container mx-auto px-4 py-8 flex-grow">
      {!isLoggedIn ? (
        <LoginPanel onLogin={handleLogin} />
      ) : (
        <Dashboard
          userRole={userRole}
          currentAgencyId={currentAgencyId}
          agenciesData={agenciesData}
          routesData={routesData}
          setRoutesData={setRoutesData}
          onLogout={handleLogout}
          onShowAddAgencyForm={() => setShowAddAgencyForm(true)}
          showAddAgencyForm={showAddAgencyForm}
          onAddAgencySubmit={handleAddAgencySubmit}
          onCloseAddAgencyForm={() => setShowAddAgencyForm(false)}
          handleAddTrip={handleAddTrip}
          showMessage={showMessage}
        />
      )}
    </div>
  );
};

export default AdminPanel;