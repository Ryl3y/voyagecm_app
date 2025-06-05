// src/components/modals/MessageModal.js
import React from 'react';
import Modal from './Modal';

const MessageModal = ({ show, onClose, title, text }) => (
    <Modal show={show} onClose={onClose}>
        <div className="text-center">
            <h3 id="message-modal-title" className="text-xl font-semibold text-emerald-700 mb-3">{title}</h3>
            <p id="message-modal-text" className="text-stone-600 mb-4">{text}</p>
            <button onClick={onClose} className="bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-2 px-6 rounded-lg">OK</button>
        </div>
    </Modal>
);

export default MessageModal;
