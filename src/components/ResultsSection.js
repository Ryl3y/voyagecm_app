// src/components/ResultsSection.js
import React from 'react';
import TripCard from './TripCard';

const ResultsSection = ({ filteredRoutes, agenciesData, onBookTrip, isLoading }) => {
    return (
        <section id="results-section" className="mb-12">
            <h3 className="text-2xl font-semibold text-emerald-700 mb-6 sr-only">Trajets Disponibles</h3>
            {isLoading ? (
                <div className="text-center py-8">
                    <div className="animate-spin rounded-full h-16 w-16 border-t-2 border-b-2 border-emerald-500 mx-auto mb-4"></div>
                    <p className="text-stone-500 text-lg">Recherche de trajets...</p>
                </div>
            ) : filteredRoutes.length > 0 ? (
                <div id="results-grid" className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {filteredRoutes.map(route => (
                        <TripCard
                            key={route.id}
                            route={route}
                            agency={agenciesData.find(a => a.id === route.agencyId)}
                            onBookTrip={onBookTrip}
                        />
                    ))}
                </div>
            ) : (
                <div id="no-results" className="text-center text-stone-500 py-8 text-lg">
                    <p>Veuillez effectuer une recherche pour voir les trajets disponibles.</p>
                    <svg className="mx-auto mt-4 w-16 h-16 text-stone-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>
                </div>
            )}
        </section>
    );
};

export default ResultsSection;
