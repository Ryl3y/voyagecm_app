// src/components/Footer.js
import React, { useState } from 'react';

const Footer = () => {
    const [currentYear, setCurrentYear] = useState(new Date().getFullYear());

    return (
        <footer className="bg-stone-800 text-stone-300 py-8 mt-16">
            <div className="container mx-auto px-4 text-center">
                <p>&copy; {currentYear} VoyageCM. Tous droits réservés.</p>
                <p className="text-sm">Une plateforme pour simplifier vos voyages interurbains au Cameroun.</p>
            </div>
        </footer>
    );
};

export default Footer;
