// src/components/Header.js
import React from 'react';

const Header = ({ currentView, setCurrentView }) => (
    <header className="bg-emerald-700 text-white shadow-lg">
        <div className="container mx-auto px-4 py-6 flex flex-col sm:flex-row justify-between items-center">
            <h1 className="text-3xl font-bold mb-4 sm:mb-0">VoyageCM</h1>
            <nav className="flex flex-col sm:flex-row items-center space-y-2 sm:space-y-0 sm:space-x-4">
                {currentView === 'public' ? (
                    <>
                        <a href="#search-section" className="px-3 py-2 hover:bg-emerald-600 rounded w-full sm:w-auto text-center">Rechercher</a>
                        <a href="#info-section" className="px-3 py-2 hover:bg-emerald-600 rounded w-full sm:w-auto text-center">À Propos</a>
                        <button
                            onClick={() => setCurrentView('admin')}
                            className="ml-0 sm:ml-4 px-3 py-2 bg-emerald-800 hover:bg-emerald-900 rounded-lg text-white font-semibold transition duration-150 w-full sm:w-auto"
                        >
                            Accès Admin/Agence
                        </button>
                    </>
                ) : (
                    <button
                        onClick={() => setCurrentView('public')}
                        className="px-3 py-2 bg-emerald-800 hover:bg-emerald-900 rounded-lg text-white font-semibold transition duration-150 w-full sm:w-auto"
                    >
                        Retour à l'application publique
                    </button>
                )}
            </nav>
        </div>
    </header>
);

export default Header;
