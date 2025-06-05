// src/components/LoginPanel.js
import React, { useState } from 'react';

const LoginPanel = ({ onLogin }) => {
    const [username, setUsername] = useState('admin'); // Admin par défaut
    const [password, setPassword] = useState('admin123'); // Mot de passe admin par défaut

    const handleSubmit = (e) => {
        e.preventDefault();
        onLogin(username, password);
    };

    return (
        <div className="bg-white p-6 md:p-8 rounded-xl shadow-2xl max-w-md mx-auto mt-12 w-full">
            <h2 className="text-3xl font-semibold text-emerald-700 mb-6 text-center">Connexion Admin/Agence</h2>
            <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                    <label htmlFor="username" className="block text-sm font-medium text-stone-700 mb-1">Nom d'utilisateur</label>
                    <input
                        type="text"
                        id="username"
                        className="w-full p-3 border border-stone-300 rounded-lg shadow-sm focus:ring-emerald-500 focus:border-emerald-500"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        required
                        placeholder="Nom d'utilisateur (ex: admin, agency1)"
                    />
                </div>
                <div>
                    <label htmlFor="password" className="block text-sm font-medium text-stone-700 mb-1">Mot de passe</label>
                    <input
                        type="password"
                        id="password"
                        className="w-full p-3 border border-stone-300 rounded-lg shadow-sm focus:ring-emerald-500 focus:border-emerald-500"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                        placeholder="Mot de passe (ex: admin123, agency123)"
                    />
                </div>
                <button type="submit" className="w-full bg-emerald-600 hover:bg-emerald-700 text-white font-semibold py-3 px-6 rounded-lg shadow-md transition duration-150 ease-in-out">
                    Se connecter
                </button>
            </form>
            <p className="text-center text-sm text-stone-500 mt-4">
                <span className="font-semibold">Admin:</span> admin / admin123 <br />
                <span className="font-semibold">Agence 1:</span> agency1 / agency123 <br />
                <span className="font-semibold">Agence 2:</span> agency2 / agency123
            </p>
        </div>
    );
};

export default LoginPanel;
