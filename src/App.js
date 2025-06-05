// src/App.js
import React, { useState, useEffect } from 'react';
import Header from './components/Header';
import SearchSection from './components/SearchSection';
import ResultsSection from './components/ResultsSection';
import InfoSection from './components/InfoSection';
import Footer from './components/Footer';
import AdminPanel from './components/AdminPanel';
import BookingModal from './components/modals/BookingModal';
import ConfirmationModal from './components/modals/ConfirmationModal';
import MessageModal from './components/modals/MessageModal';

// Importation des données initiales
import initialAgenciesData from './data/agenciesData';
import initialRoutesData from './data/routesData';

// Composant principal de l'application
function App() {
    // État pour gérer la vue actuelle (public ou admin)
    const [currentView, setCurrentView] = useState('public');

    // Données des agences et des itinéraires (maintenant des états modifiables)
    const [agenciesData, setAgenciesData] = useState(initialAgenciesData);
    const [routesData, setRoutesData] = useState(initialRoutesData);

    const [filteredRoutes, setFilteredRoutes] = useState([]);
    const [selectedTripForBooking, setSelectedTripForBooking] = useState(null);
    const [showBookingModal, setShowBookingModal] = useState(false);
    const [showConfirmationModal, setShowConfirmationModal] = useState(false);
    const [showMessageModal, setShowMessageModal] = useState(false);
    const [messageModalContent, setMessageModalContent] = useState({ title: '', text: '' });
    const [bookingCode, setBookingCode] = useState('');
    const [isLoading, setIsLoading] = useState(false); // Pour l'état de chargement

    // Fonction pour afficher la modale de message
    const showMessage = (title, text) => {
        setMessageModalContent({ title, text });
        setShowMessageModal(true);
    };

    // Fonction pour ajouter une nouvelle agence
    const handleAddAgency = (newAgency) => {
        setAgenciesData(prevData => [...prevData, newAgency]);
    };

    // Fonction pour ajouter un nouveau trajet
    const handleAddTrip = (newTrip) => {
        setRoutesData(prevRoutes => [...prevRoutes, newTrip]);
    };

    // Fonction pour mettre à jour un trajet (utilisé pour la réservation de siège)
    const handleUpdateTrip = (updatedTrip) => {
        setRoutesData(prevRoutes =>
            prevRoutes.map(route => (route.id === updatedTrip.id ? updatedTrip : route))
        );
    };

    // Fonction de recherche
    const handleSearch = (departureCity, arrivalCity, travelDate) => {
        setIsLoading(true);
        // Simulation d'un délai de chargement
        setTimeout(() => {
            if (!travelDate) {
                showMessage("Date manquante", "Veuillez sélectionner une date de voyage.");
                setFilteredRoutes([]);
                setIsLoading(false);
                return;
            }
            if (departureCity === arrivalCity) {
                showMessage("Erreur de sélection", "La ville de départ et la ville d'arrivée ne peuvent pas être identiques.");
                setFilteredRoutes([]);
                setIsLoading(false);
                return;
            }

            const results = routesData.filter(route =>
                route.departureCity === departureCity && route.arrivalCity === arrivalCity
            );
            setFilteredRoutes(results);
            setIsLoading(false);
        }, 500); // Délai de 0.5 seconde pour simuler le chargement
    };

    // Fonction pour ouvrir la modale de réservation
    const handleBookTrip = (routeId) => {
        const trip = routesData.find(r => r.id === routeId);
        if (trip) {
            setSelectedTripForBooking(trip);
            setShowBookingModal(true);
        } else {
            showMessage("Erreur", "Trajet non trouvé."); // Notifier l'utilisateur si le trajet n'est pas trouvé
        }
    };

    // Fonction pour confirmer la réservation (simulation)
    const handleConfirmBooking = (passengerDetails, selectedSeatNumber) => {
        if (!passengerDetails || typeof passengerDetails.name !== 'string' || passengerDetails.name.trim() === '') {
            showMessage("Information manquante", "Veuillez entrer le nom complet du passager.");
            return;
        }
        if (!selectedSeatNumber) {
            showMessage("Siège manquant", "Veuillez sélectionner un numéro de siège.");
            return;
        }

        // Trouver le trajet et le siège
        const tripIndex = routesData.findIndex(t => t.id === selectedTripForBooking.id);
        if (tripIndex === -1) {
            showMessage("Erreur", "Trajet introuvable.");
            return;
        }

        const currentTrip = { ...routesData[tripIndex] };
        const seatIndex = selectedSeatNumber - 1;

        if (currentTrip.seats[seatIndex]) {
            // Siège déjà occupé
            const availableSeatsList = currentTrip.seats
                .map((isOccupied, index) => (isOccupied ? null : index + 1))
                .filter(seat => seat !== null);
            showMessage(
                "Siège occupé",
                `Le siège ${selectedSeatNumber} est déjà pris. Sièges disponibles : ${availableSeatsList.join(', ')}`
            );
            return;
        }

        // Marquer le siège comme occupé et réduire le nombre de sièges disponibles
        currentTrip.seats[seatIndex] = true;
        currentTrip.availableSeats -= 1;

        // Mettre à jour les données des trajets
        handleUpdateTrip(currentTrip);

        setShowBookingModal(false);
        setBookingCode(`CM-${Date.now().toString().slice(-6)}-S${selectedSeatNumber}`);
        setShowConfirmationModal(true);
    };

    return (
        <div className="bg-stone-100 text-stone-800 min-h-screen flex flex-col">
            <Header currentView={currentView} setCurrentView={setCurrentView} />
            {currentView === 'public' ? (
                <main className="container mx-auto px-4 py-8 flex-grow">
                    <SearchSection onSearch={handleSearch} />
                    <ResultsSection
                        filteredRoutes={filteredRoutes}
                        agenciesData={agenciesData}
                        onBookTrip={handleBookTrip}
                        isLoading={isLoading}
                    />
                    <InfoSection />
                </main>
            ) : (
                <AdminPanel
                    agenciesData={agenciesData}
                    setAgenciesData={setAgenciesData}
                    routesData={routesData}
                    setRoutesData={setRoutesData}
                    onBackToPublic={() => setCurrentView('public')}
                    showMessage={showMessage}
                    handleAddTrip={handleAddTrip}
                />
            )}
            <Footer />

            {/* Modales */}
            <BookingModal
                show={showBookingModal}
                onClose={() => setShowBookingModal(false)}
                selectedTrip={selectedTripForBooking}
                agenciesData={agenciesData}
                onConfirmBooking={handleConfirmBooking}
                showMessage={showMessage}
            />
            <ConfirmationModal
                show={showConfirmationModal}
                onClose={() => setShowConfirmationModal(false)}
                bookingCode={bookingCode}
            />
            <MessageModal
                show={showMessageModal}
                onClose={() => setShowMessageModal(false)}
                title={messageModalContent.title}
                text={messageModalContent.text}
            />
        </div>
    );
}

export default App;
