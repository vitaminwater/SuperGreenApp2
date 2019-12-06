import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:super_green_app/apis/device/kv_device.dart';
import 'package:super_green_app/models/device/device_data.dart';
import 'package:wifi_iot/wifi_iot.dart';

abstract class NewDeviceBlocEvent extends Equatable {}

class NewDeviceBlocEventStartSearch extends NewDeviceBlocEvent {
  @override
  List<Object> get props => [];
}

abstract class NewDeviceBlocState extends Equatable {}

class NewDeviceBlocStateIdle extends NewDeviceBlocState {
  @override
  List<Object> get props => [];
}

class NewDeviceBlocStateMissingPermission extends NewDeviceBlocState {
  @override
  List<Object> get props => [];
}

class NewDeviceBlocStateResolving extends NewDeviceBlocState {
  @override
  List<Object> get props => [];
}

class NewDeviceBlocStateFound extends NewDeviceBlocState {
  @override
  List<Object> get props => [];
}

class NewDeviceBlocStateNotFound extends NewDeviceBlocState {
  @override
  List<Object> get props => [];
}

class NewDeviceBlocStateOutdated extends NewDeviceBlocState {
  @override
  List<Object> get props => [];
}

class NewDeviceBlocStateDone extends NewDeviceBlocState {
  final DeviceData deviceData;
  NewDeviceBlocStateDone(this.deviceData);

  @override
  List<Object> get props => [deviceData];
}

class NewDeviceBloc extends Bloc<NewDeviceBlocEvent, NewDeviceBlocState> {

  final PermissionHandler _permissionHandler = PermissionHandler();

    @override
  NewDeviceBlocState get initialState => NewDeviceBlocStateIdle();

  NewDeviceBloc() {
    this.add(NewDeviceBlocEventStartSearch());
  }

  @override
  Stream<NewDeviceBlocState> mapEventToState(NewDeviceBlocEvent event) async* {
    if (event is NewDeviceBlocEventStartSearch) {
      yield* this._startSearch(event);
    }
  }

  Stream<NewDeviceBlocState> _startSearch(NewDeviceBlocEventStartSearch event) async* {
    if (Platform.isIOS && await _permissionHandler.checkPermissionStatus(PermissionGroup.locationWhenInUse) != PermissionStatus.granted) {
      final result = await _permissionHandler.requestPermissions([PermissionGroup.locationWhenInUse]);
      if (result[PermissionGroup.locationWhenInUse] != PermissionStatus.granted) {
        yield NewDeviceBlocStateMissingPermission();
        return;
      }
    }
    final currentSSID = await WiFiForIoTPlugin.getSSID();
    if (currentSSID != '🤖🍁') {
      await WiFiForIoTPlugin.connect('🤖🍁', password: 'multipass', security: NetworkSecurity.WPA);
    }
  }
}