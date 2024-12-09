async function refreshForecast() {
    console.log('refreshForecast started'); // Debug log
    const forecastDiv = document.getElementById('forecast');
    const hannoDiv = document.getElementById('hanno-prediction');
    const compassDiv = document.getElementById('compass-helmet');
    
    console.log('Elements found:', { forecastDiv, hannoDiv, compassDiv }); // Debug log
    
    forecastDiv.innerHTML = 'Loading...';
    
    const forecast = await getForecast();
    console.log('Forecast data:', forecast); // Debug log
    
    if (forecast) {
        // ... rest of the code ...
    } else {
        forecastDiv.innerHTML = 'Error getting forecast';
    }
}

// Initial load
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM Content Loaded'); // Debug log
    refreshForecast();
});
