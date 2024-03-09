# Quanos Weather App

Welcome to Quanos Weather App

## Features

- **Location-Based Weather**: Upon opening the app, Quanos Weather App automatically requests your device's location to fetch the current weather data for your area.
- **Search Functionality**: If you want to check the weather for a specific location, simply use the search option to find weather information for any city around the world.
- **Pull-to-Refresh**: You can also manually refresh the weather data by dragging the screen down to ensure you always have the latest weather updates.
- **User-Friendly Interface**: Quanos Weather App boasts a sleek and intuitive interface, making it easy for users to navigate and access the weather information they need.

## Getting Started

Follow these steps to get started with Quanos Weather App:

### Setting Up API Key

To use the app, you need to provide your own API key for weather data. Follow these steps to set up your API key:

1. Create an account on the OpenWeatherMap website.
2. Generate an API key in your account dashboard.
3. Copy the API key.
4. In the project directory, create a new file named `config.json` in the `config` directory.
5. Open the `config.json` file and paste your API key in the following format:

   ```json
   {
     "API_KEY": "YOUR_API_KEY_HERE"
   }


1. **Clone the repository**: 
   ```sh
   git clone https://github.com/yourusername/quanos_weather_app.git
   ```

2. **Navigate to the project directory**: 
   ```sh
   cd quanos_weather_app
   ```

3. **Install dependencies**: 
   ```sh
   flutter pub get
   ```

4. **Run the app on an emulator or physical device including the config.json file**: 
   ```sh
   flutter run --dart-define-from-file=config/config.json
   ```

5. **Grant Location Access**: Upon opening the app, you will be prompted to grant location access. Allow the app to access your location to fetch current weather data.

6. **Explore the App**:
   - **View Current Weather**: The app will display the current weather for your location.
   - **Search for Locations**: Use the search bar to find weather information for other cities worldwide.
   - **Refresh Data**: Drag the app screen down to refresh the weather data.
