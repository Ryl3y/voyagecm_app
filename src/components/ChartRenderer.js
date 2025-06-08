// src/components/ChartRenderer.js
import React, { useEffect, useRef } from 'react';
import {Chart} from 'chart.js';
// Chart.js est importé via CDN dans public/index.html, donc pas besoin d'import ici pour le moment.
// Pour une installation npm: import { Chart } from 'chart.js';

const ChartRenderer = () => {
    const transportModeChartRef = useRef(null);
    const mobileMoneyChartRef = useRef(null);

    useEffect(() => {
        // Ajout d'une vérification pour s'assurer que Chart est disponible globalement
        if (typeof Chart === 'undefined') {
            console.error("Chart.js n'est pas disponible globalement. Assurez-vous qu'il est chargé via un CDN ou installé via npm.");
            return;
        }

        // Détruire les instances de graphique existantes avant de les recréer
        if (transportModeChartRef.current) {
            transportModeChartRef.current.destroy();
        }
        if (mobileMoneyChartRef.current) {
            mobileMoneyChartRef.current.destroy();
        }

        const transportModeCtx = document.getElementById('transportModeChart')?.getContext('2d');
        if (transportModeCtx) {
            transportModeChartRef.current = new Chart(transportModeCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Transport Routier', 'Autres Modes'],
                    datasets: [{
                        label: 'Part des Modes de Transport',
                        data: [85, 15],
                        backgroundColor: ['#059669', '#a7f3d0'],
                        borderColor: ['#047857', '#6ee7b7'],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'top', labels: { color: '#374151' } },
                        title: { display: true, text: 'Prédominance du Transport Routier au Cameroun', color: '#1f2937', font: {size: 14}}
                    }
                }
            });
        }

        const mobileMoneyCtx = document.getElementById('mobileMoneyChart')?.getContext('2d');
        if (mobileMoneyCtx) {
            mobileMoneyChartRef.current = new Chart(mobileMoneyCtx, {
                type: 'line',
                data: {
                    labels: ['2017', '2018', '2019', '2020', '2021', '2022'],
                    datasets: [{
                        label: 'Adoption Mobile Money (%)',
                        data: [29.9, 33.5, 37.0, 39.5, 41.0, 42.7],
                        fill: false,
                        borderColor: '#fb923c',
                        tension: 0.1,
                        pointBackgroundColor: '#f97316',
                        pointRadius: 5
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: { y: { beginAtZero: false, ticks: { color: '#374151' } }, x: { ticks: { color: '#374151' } } },
                    plugins: {
                        legend: { display: false },
                        title: { display: true, text: 'Croissance de l\'Adoption Mobile Money', color: '#1f2937', font: {size: 14} }
                    }
                }
            });
        }

        // Fonction de nettoyage pour détruire les graphiques lors du démontage du composant
        return () => {
            if (transportModeChartRef.current) {
                transportModeChartRef.current.destroy();
            }
            if (mobileMoneyChartRef.current) {
                mobileMoneyChartRef.current.destroy();
            }
        };
    }, []); // Le tableau vide assure que l'effet ne s'exécute qu'une fois après le montage initial

    return null; // Ce composant ne rend rien directement, il gère les graphiques
};

export default ChartRenderer;
