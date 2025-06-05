// src/components/forms/AddAgencyForm.js
import React, { useState } from 'react';

const AddAgencyForm = ({ onSubmit, onClose }) => {
    const [name, setName] = useState('');
    const [logo, setLogo] = useState('');
    const [verified, setVerified] = useState(false);
    const [services, setServices] = useState('');
    const [imageUrl, setImageUrl] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        onSubmit({ name, logo, verified, services, imageUrl });
        // Réinitialiser le formulaire
        setName('');
        setLogo('');
        setVerified(false);
        setServices('');
        setImageUrl('');
    };

    return (
        <div className="bg-white p-6 rounded-xl shadow-md mb-8 w-full">
            <h3 className="text-2xl font-semibold text-emerald-700 mb-4">Ajouter une nouvelle agence</h3>
            <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                    <label htmlFor="agency-name" className="block text-sm font-medium text-stone-700 mb-1">Nom de l'agence</label>
                    <input type="text" id="agency-name" className="w-full p-2 border border-stone-300 rounded-md shadow-sm" value={name} onChange={(e) => setName(e.target.value)} required />
                </div>
                <div>
                    <label htmlFor="agency-logo" className="block text-sm font-medium text-stone-700 mb-1">Logo (Emoji ou texte court)</label>
                    <input type="text" id="agency-logo" className="w-full p-2 border border-stone-300 rounded-md shadow-sm" value={logo} onChange={(e) => setLogo(e.target.value)} />
                </div>
                <div>
                    <label htmlFor="agency-services" className="block text-sm font-medium text-stone-700 mb-1">Services (séparés par des virgules)</label>
                    <input type="text" id="agency-services" className="w-full p-2 border border-stone-300 rounded-md shadow-sm" value={services} onChange={(e) => setServices(e.target.value)} placeholder="Ex: VIP, Climatisé, Toilettes" />
                </div>
                <div>
                    <label htmlFor="agency-image-url" className="block text-sm font-medium text-stone-700 mb-1">URL de l'image du bus (facultatif)</label>
                    <input type="url" id="agency-image-url" className="w-full p-2 border border-stone-300 rounded-md shadow-sm" value={imageUrl} onChange={(e) => setImageUrl(e.target.value)} placeholder="Ex: https://placehold.co/150x80/..." />
                </div>
                <div className="flex items-center">
                    <input type="checkbox" id="agency-verified" className="h-4 w-4 text-emerald-600 border-stone-300 rounded" checked={verified} onChange={(e) => setVerified(e.target.checked)} />
                    <label htmlFor="agency-verified" className="ml-2 block text-sm text-stone-700">Agence vérifiée</label>
                </div>
                <div className="flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-4 mt-4">
                    <button type="button" onClick={onClose} className="bg-stone-300 hover:bg-stone-400 text-stone-800 font-semibold py-2 px-4 rounded-lg transition duration-150 w-full sm:w-auto">
                        Annuler
                    </button>
                    <button type="submit" className="bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-2 px-4 rounded-lg transition duration-150 w-full sm:w-auto">
                        Ajouter l'agence
                    </button>
                </div>
            </form>
        </div>
    );
};

export default AddAgencyForm;
