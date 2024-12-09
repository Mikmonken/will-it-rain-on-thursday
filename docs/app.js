const API_KEY = '85ed5a0f3ae71aeebd8eb08ffe1eec4b';  // We'll change this to use GitHub secrets later

async function getForecast() {
    try {
        const response = await fetch(`https://api.openweathermap.org/data/2.5/forecast?lat=53.2587&lon=-2.1270&appid=${API_KEY}&units=metric`);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Error fetching forecast:', error);
        return null;
    }
}

function getHannoDelay() {
    return Math.floor(Math.random() * 15) + 1;
}

function getHelmetTilt() {
    return Math.floor(Math.random() * 45) + 1;
}

async function refreshForecast() {
    const forecastDiv = document.getElementById('forecast');
    const hannoDiv = document.getElementById('hanno-prediction');
    const compassDiv = document.getElementById('compass-helmet');
    
    forecastDiv.innerHTML = 'Loading...';
    
    const forecast = await getForecast();
    if (forecast) {
        const probability = Math.round(forecast.list[0].pop * 100);
        const willRain = probability > 50;
        
        forecastDiv.innerHTML = `
            <h2>${willRain ? 'Yes, it will rain' : 'No, it won\'t rain'}</h2>
            <p>${probability}% chance of rain</p>
        `;
        
        const hannoDelay = getHannoDelay();
        hannoDiv.innerHTML = `
            <div class="prediction">
                <h3>Hanno will be ${hannoDelay} minutes late</h3>
            </div>
        `;
        
        const helmetTilt = getHelmetTilt();
        compassDiv.innerHTML = `
            <div class="prediction">
                <h3>Compass's Helmet</h3>
                <p>${helmetTilt}° off-center</p>
                <p>${helmetTilt > 30 ? 'Very wonky!' : (helmetTilt > 15 ? 'Quite wonky' : 'Slightly wonky')}</p>
            </div>
        `;
    } else {
        forecastDiv.innerHTML = 'Error getting forecast';
    }
}

// Initial load
document.addEventListener('DOMContentLoaded', refreshForecast); 
