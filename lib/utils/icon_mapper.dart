class IconMapper {
  static String getLocalWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/icons/sun.gif';
      case 'clouds':
        return 'assets/icons/clouds.gif';
      case 'rain':
        return 'assets/icons/rain.gif';
      case 'snow':
        return 'assets/icons/snow.gif';
      case 'mist':
      case 'fog':
        return 'assets/icons/fog.gif';
      default:
        return 'assets/icons/sun.gif';
    }
  }
}
