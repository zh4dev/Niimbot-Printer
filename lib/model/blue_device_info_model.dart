class BlueDeviceInfoModel {
  BlueDeviceInfoModel({
    String? deviceName,
    String? deviceHardwareAddress,
    num? connectionState,
  }) {
    _deviceName = deviceName;
    _deviceHardwareAddress = deviceHardwareAddress;
    _connectionState = connectionState;
  }

  BlueDeviceInfoModel.fromJson(dynamic json) {
    _deviceName = json['deviceName'];
    _deviceHardwareAddress = json['deviceHardwareAddress'];
    _connectionState = json['connectionState'];
  }

  String? _deviceName;
  String? _deviceHardwareAddress;
  num? _connectionState;
  bool isLoading = false;

  BlueDeviceInfoModel copyWith({
    String? deviceName,
    String? deviceHardwareAddress,
    num? connectionState,
  }) =>
      BlueDeviceInfoModel(
        deviceName: deviceName ?? _deviceName,
        deviceHardwareAddress: deviceHardwareAddress ?? _deviceHardwareAddress,
        connectionState: connectionState ?? _connectionState,
      );

  String? get deviceName => _deviceName;

  String? get deviceHardwareAddress => _deviceHardwareAddress;

  num? get connectionState => _connectionState;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['deviceName'] = _deviceName;
    map['deviceHardwareAddress'] = _deviceHardwareAddress;
    map['connectionState'] = _connectionState;
    return map;
  }
}
