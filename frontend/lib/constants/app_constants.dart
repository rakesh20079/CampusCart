class AppConstants {
  static const String appName = 'Campus Cart';
  static const String appTagline = 'Collegiate Peer-to-Peer Marketplace';

  // Your machine's current local Wi-Fi IP on the network (for local LAN testing)
  static const String localLanIp = '10.233.28.247';

  // Live AWS EC2 Cloud Server URL
  static const String productionBaseUrl = 'http://51.20.86.132:8080';

  // Automatically adjust base URL:
  // Points directly to your live AWS EC2 server
  static String get defaultBaseUrl {
    const String envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    return productionBaseUrl;
  }

  // Pre-configured campus zones for quick selection
  static const List<String> campusZones = [
    'Main Campus',
    'North Campus Library Hub',
    'Engineering Quad',
    'Science & Lab Complex',
    'South Campus Hostel Area',
    'Student Activity Center',
  ];
}
