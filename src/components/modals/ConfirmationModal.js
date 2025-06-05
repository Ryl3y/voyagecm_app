// src/components/modals/ConfirmationModal.js
import React from 'react';
import Modal from './Modal';

const ConfirmationModal = ({ show, onClose, bookingCode }) => (
    <Modal show={show} onClose={onClose}>
        <div className="text-center">
            <div className="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-green-100 mb-4">
                <svg className="h-10 w-10 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7"></path></svg>
            </div>
            <h3 className="text-2xl font-semibold text-emerald-700 mb-3">Réservation Confirmée !</h3>
            <p className="text-stone-600 mb-2">Votre billet a été réservé avec succès (simulation).</p>
            <p className="text-stone-600 mb-1"><strong>Code de réservation :</strong> <span id="booking-code" className="font-mono text-emerald-600">{bookingCode}</span></p>
            <p className="text-stone-600 mb-4">Merci d'utiliser VoyageCM !</p>
            <button onClick={onClose} className="bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-2 px-6 rounded-lg">OK</button>
        </div>
    </Modal>
);

export default ConfirmationModal;
