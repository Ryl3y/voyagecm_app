// src/components/InfoSection.js
import React, { useState } from 'react';
import TabContent from './TabContent';
import ChartRenderer from './ChartRenderer';

const InfoSection = () => {
    const [activeTab, setActiveTab] = useState('why-us');

    return (
        <section id="info-section" className="bg-white p-6 md:p-8 rounded-xl shadow-xl mb-12">
            <h2 className="text-3xl font-semibold text-emerald-700 mb-8 text-center">Découvrez VoyageCM</h2>
            <p className="text-stone-600 mb-8 text-center max-w-2xl mx-auto">VoyageCM est votre nouvelle plateforme de confiance pour simplifier vos voyages interurbains au Cameroun. Nous connectons les voyageurs avec des agences vérifiées, offrant une expérience de réservation transparente, sécurisée et pratique.</p>

            <div className="mb-6 border-b border-stone-200">
                <nav className="flex flex-wrap -mb-px justify-center" aria-label="Tabs">
                    <button
                        className={`tab-button py-4 px-1 inline-flex items-center gap-2 border-b-[3px] border-transparent text-md whitespace-nowrap text-stone-500 hover:text-emerald-600 ${activeTab === 'why-us' ? 'active bg-emerald-600 text-white' : ''}`}
                        onClick={() => setActiveTab('why-us')}
                    >Pourquoi nous choisir ?</button>
                    <button
                        className={`tab-button py-4 px-1 ml-4 inline-flex items-center gap-2 border-b-[3px] border-transparent text-md whitespace-nowrap text-stone-500 hover:text-emerald-600 ${activeTab === 'partners' ? 'active bg-emerald-600 text-white' : ''}`}
                        onClick={() => setActiveTab('partners')}
                    >Agences Partenaires</button>
                    <button
                        className={`tab-button py-4 px-1 ml-4 inline-flex items-center gap-2 border-b-[3px] border-transparent text-md whitespace-nowrap text-stone-500 hover:text-emerald-600 ${activeTab === 'payment' ? 'active bg-emerald-600 text-white' : ''}`}
                        onClick={() => setActiveTab('payment')}
                    >Paiement Mobile Money</button>
                    <button
                        className={`tab-button py-4 px-1 ml-4 inline-flex items-center gap-2 border-b-[3px] border-transparent text-md whitespace-nowrap text-stone-500 hover:text-emerald-600 ${activeTab === 'security' ? 'active bg-emerald-600 text-white' : ''}`}
                        onClick={() => setActiveTab('security')}
                    >Engagement Sécurité</button>
                </nav>
            </div>

            <TabContent id="why-us" activeTab={activeTab}>
                <h3 className="text-xl font-semibold text-emerald-600 mb-3">Simplicité, Transparence et Confiance</h3>
                <p className="text-stone-600 mb-4">Notre mission est de rendre vos réservations de voyage interurbain aussi simples et sécurisées que possible. Nous nous concentrons sur :</p>
                <ul className="list-disc list-inside text-stone-600 mb-4 space-y-1">
                    <li>Une plateforme intuitive pour trouver et comparer les trajets.</li>
                    <li>Des informations claires sur les horaires, tarifs et services.</li>
                    <li>Un processus de réservation rapide et sans tracas.</li>
                    <li>La mise en avant d'agences engagées pour la qualité et la sécurité.</li>
                </ul>
                <p className="text-stone-600 mb-4">Le transport routier est vital au Cameroun, représentant la grande majorité des déplacements interurbains. Notre application est conçue pour optimiser cette expérience essentielle.</p>
                <div className="chart-container mx-auto mt-6">
                    <canvas id="transportModeChart"></canvas>
                </div>
            </TabContent>

            <TabContent id="partners" activeTab={activeTab}>
                <h3 className="text-xl font-semibold text-emerald-600 mb-3">Nos Agences Partenaires de Confiance</h3>
                <p className="text-stone-600 mb-4">Nous collaborons avec des agences de transport reconnues pour leur sérieux et la qualité de leurs services. Pour le lancement de notre MVP, nous nous concentrons sur des acteurs majeurs pour vous garantir une expérience fiable. Voici quelques exemples (liste indicative pour le MVP) :</p>
                <ul className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <li className="bg-stone-50 p-4 rounded-lg shadow">
                        <h4 className="font-semibold text-emerald-700">🚌 Touristique Express</h4>
                        <p className="text-sm text-stone-500">Yaoundé - Douala, Bus climatisés, respect des horaires.</p>
                    </li>
                    <li className="bg-stone-50 p-4 rounded-lg shadow">
                        <h4 className="font-semibold text-emerald-700">🚍 Buca Voyages</h4>
                        <p className="text-sm text-stone-500">Douala - Yaoundé - Mbalmayo, Bus rénovés, départs réguliers.</p>
                    </li>
                    <li className="bg-stone-50 p-4 rounded-lg shadow">
                        <h4 className="font-semibold text-emerald-700">🚐 Amour Mezam Express</h4>
                        <p className="text-sm text-stone-500">Yaoundé - Bamenda, Transport de passagers et colis.</p>
                    </li>
                    <li className="bg-stone-50 p-4 rounded-lg shadow">
                        <h4 className="font-semibold text-emerald-700">JourneyMEN TRAVEL</h4>
                        <p className="text-sm text-stone-500">Yaoundé - Kribi, Ligne confort.</p>
                    </li>
                </ul>
                <p className="text-stone-600 mt-4">Notre processus de vérification assure que les agences listées respectent les normes de sécurité et de conformité.</p>
            </TabContent>

            <TabContent id="payment" activeTab={activeTab}>
                <h3 className="text-xl font-semibold text-emerald-600 mb-3">Paiement Facile et Sécurisé avec Mobile Money</h3>
                <p className="text-stone-600 mb-4">Au Cameroun, Mobile Money est devenu un moyen de paiement incontournable, plébiscité pour sa simplicité et son accessibilité. Notre application intègre les paiements via :</p>
                <div className="flex space-x-4 mb-4">
                    <span className="bg-yellow-400 text-black px-4 py-2 rounded-md font-bold">MTN MoMo</span>
                    <span className="bg-orange-500 text-white px-4 py-2 rounded-md font-bold">Orange Money</span>
                </div>
                <p className="text-stone-600 mb-4">Payer votre billet en ligne est non seulement pratique, mais aussi encouragé par les récentes évolutions réglementaires (Loi de Finances 2024) favorisant les transactions électroniques. Nous assurons la sécurité de vos paiements pour une tranquillité d'esprit totale.</p>
                <div className="chart-container mx-auto mt-6">
                    <canvas id="mobileMoneyChart"></canvas>
                </div>
            </TabContent>

            <TabContent id="security" activeTab={activeTab}>
                <h3 className="text-xl font-semibold text-emerald-600 mb-3">Votre Sécurité, Notre Priorité</h3>
                <p className="text-stone-600 mb-4">Nous comprenons que la sécurité est une préoccupation majeure pour les voyageurs. C'est pourquoi nous nous engageons à :</p>
                <ul className="list-disc list-inside text-stone-600 mb-4 space-y-1">
                    <li>✅ Partenariat avec des agences de transport qui s'engagent à respecter les normes de sécurité et réglementations en vigueur.</li>
                    <li>🛡️ Promotion de la transparence : informations claires sur les agences et les services.</li>
                    <li>🔄 Encourager les retours d'expérience pour améliorer continuellement la qualité des services (fonctionnalité future).</li>
                </ul>
                <p className="text-stone-600">En choisissant notre plateforme, vous optez pour une démarche qui valorise la fiabilité et la sérénité de vos déplacements.</p>
            </TabContent>

            <ChartRenderer />
        </section>
    );
};

export default InfoSection;
