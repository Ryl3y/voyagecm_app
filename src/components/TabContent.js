// src/components/TabContent.js
import React from 'react';

const TabContent = ({ id, activeTab, children }) => (
    <div id={id} className={`p-4 ${activeTab === id ? 'block' : 'hidden'}`}>
        {children}
    </div>
);

export default TabContent;
