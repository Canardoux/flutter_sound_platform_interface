/*
 * Copyright 2018, 2019, 2020, 2021 canardoux.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

//import 'dart:async';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart' show Level;
import 'dart:core';
import 'flutter_sound_player_platform_interface.dart';
import 'flutter_sound_platform_interface.dart';
import 'dart:typed_data' show Uint8List, Float32List, Int16List;

const MethodChannel _channel =
    MethodChannel('xyz.canardoux.flutter_sound_player');

/// An implementation of [FlutterSoundPlayerPlatform] that uses method channels.
class MethodChannelFlutterSoundPlayer extends FlutterSoundPlayerPlatform {
  /* ctor */ MethodChannelFlutterSoundPlayer() {
    setCallback();
  }

  void setCallback() {
    //_channel = const MethodChannel('xyz.canardoux.flutter_sound_player');
    _channel.setMethodCallHandler((MethodCall call) {
      return channelMethodCallHandler(call);
    });
  }

  Future<bool> channelMethodCallHandler(MethodCall call) {
    return Future<bool>(() {
      FlutterSoundPlayerCallback aPlayer =
          getSession(call.arguments!['slotNo'] as int);
      Map arg = call.arguments;

      bool success = call.arguments['success'] != null
          ? call.arguments['success'] as bool
          : false;
      if (arg['state'] != null) aPlayer.updatePlaybackState(arg['state']);

      switch (call.method) {
        case "updateProgress":
          {
            aPlayer.updateProgress(
                duration: arg['duration'], position: arg['position']);
          }
          break;

        case "needSomeFood":
          {
            aPlayer.needSomeFood(arg['arg']);
          }
          break;

        case "audioPlayerFinishedPlaying":
          {
            aPlayer.audioPlayerFinished(arg['arg']);
          }
          break;

        case 'updatePlaybackState':
          {
            aPlayer.updatePlaybackState(arg['arg']);
          }
          break;

        case 'openPlayerCompleted':
          {
            aPlayer.openPlayerCompleted(call.arguments['state'], success);
          }
          break;

        case 'startPlayerCompleted':
          {
            int duration = arg['duration'] as int;
            aPlayer.startPlayerCompleted(
                call.arguments['state'], success, duration);
          }
          break;

        case "stopPlayerCompleted":
          {
            aPlayer.stopPlayerCompleted(call.arguments['state'], success);
          }
          break;

        case "pausePlayerCompleted":
          {
            aPlayer.pausePlayerCompleted(call.arguments['state'], success);
          }
          break;

        case "resumePlayerCompleted":
          {
            aPlayer.resumePlayerCompleted(call.arguments['state'], success);
          }
          break;

        case "log":
          {
            int i = call.arguments['level'];
            Level l = Level.values.firstWhere((x) => x.value == i);
            aPlayer.log(l, call.arguments['msg']);
          }
          break;

        default:
          throw ArgumentError('Unknown method ${call.method}');
      }
      return success;
    });
  }

//===============================================================================================================================

  Future<int> invokeMethod(FlutterSoundPlayerCallback callback,
      String methodName, Map<String, dynamic> call) async {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as int;
  }

  Future<String> invokeMethodString(FlutterSoundPlayerCallback callback,
      String methodName, Map<String, dynamic> call) async {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as String;
  }

  Future<bool> invokeMethodBool(FlutterSoundPlayerCallback callback,
      String methodName, Map<String, dynamic> call) async {
    call['slotNo'] = findSession(callback);
    return await _channel.invokeMethod(methodName, call) as bool;
  }

  Future<Map> invokeMethodMap(FlutterSoundPlayerCallback callback,
      String methodName, Map<String, dynamic> call) async {
    call['slotNo'] = findSession(callback);
    var r = await _channel.invokeMethod(methodName, call);
    return r;
  }

  @override
  Future<bool> initPlugin() async {
    // Nothing special todo
    return true;
  }

  @override
  Future<void>? setLogLevel(
      FlutterSoundPlayerCallback callback, Level logLevel) {
    return invokeMethod(callback, 'setLogLevel', {
      'logLevel': logLevel.index,
    });
  }

  @override
  Future<void>? resetPlugin(
    FlutterSoundPlayerCallback callback,
  ) {
    return _channel.invokeMethod(
      'resetPlugin',
    );
  }

  @override
  Future<int> openPlayer(FlutterSoundPlayerCallback callback,
      {required Level logLevel}) {
    return invokeMethod(
      callback,
      'openPlayer',
      {'logLevel': logLevel.index},
    );
  }

  @override
  Future<int> closePlayer(
    FlutterSoundPlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'closePlayer',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<int> getPlayerState(
    FlutterSoundPlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'getPlayerState',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<Map<String, Duration>> getProgress(
    FlutterSoundPlayerCallback callback,
  ) async {
    var m2 = await invokeMethodMap(
      callback,
      'getProgress',
      Map<String, dynamic>(),
    );
    Map<String, Duration> r = {
      'duration': Duration(milliseconds: m2['duration']!),
      'progress': Duration(milliseconds: m2['position']!),
    };
    return r;
  }

  @override
  Future<bool> isDecoderSupported(
    FlutterSoundPlayerCallback callback, {
    Codec codec = Codec.defaultCodec,
  }) {
    return invokeMethodBool(
      callback,
      'isDecoderSupported',
      {
        'codec': codec.index,
      },
    );
  }

  @override
  Future<int> setSubscriptionDuration(
    FlutterSoundPlayerCallback callback, {
    Duration? duration,
  }) {
    return invokeMethod(
      callback,
      'setSubscriptionDuration',
      {'duration': duration!.inMilliseconds},
    );
  }

  @override
  Future<int> startPlayer(
    FlutterSoundPlayerCallback callback, {
    Codec? codec,
    bool interleaved = true,
    Uint8List? fromDataBuffer,
    String? fromURI,
    int? numChannels,
    int? sampleRate,
    int bufferSize = 20480,
  }) {
    return invokeMethod(
      callback,
      'startPlayer',
      {
        'codec': codec!.index,
        'interleaved': interleaved,
        'fromDataBuffer': fromDataBuffer,
        'fromURI': fromURI,
        'numChannels': numChannels,
        'sampleRate': sampleRate,
        'bufferSize': bufferSize,
      },
    );
  }

  @override
  Future<int> startPlayerFromStream(
    FlutterSoundPlayerCallback callback, {
    Codec codec = Codec.pcm16,
    bool interleaved = true,
    int numChannels = 1,
    int sampleRate = 16000,
    int bufferSize = 8192,
    //TWhenFinished? whenFinished,
  }) {
    return startPlayer(callback,
        codec: codec,
        interleaved: interleaved,
        numChannels: numChannels,
        sampleRate: sampleRate,
        bufferSize: bufferSize);
  }

  @override

  ///@deprecated
  Future<int> startPlayerFromMic(FlutterSoundPlayerCallback callback,
      {int? numChannels,
      int? sampleRate,
      int bufferSize = 20480,
      bool enableVoiceProcessing = false}) {
    return invokeMethod(
      callback,
      'startPlayerFromMic',
      {
        'numChannels': numChannels,
        'sampleRate': sampleRate,
        'bufferSize': bufferSize,
        'enableVoiceProcessing': enableVoiceProcessing ? 1 : 0,
      },
    );
  }

  @override
  Future<int> feed(
    FlutterSoundPlayerCallback callback, {
    Uint8List? data,
  }) {
    return invokeMethod(
      callback,
      'feed',
      {
        'data': data,
      },
    );
  }

  Future<int> feedFloat32(
    FlutterSoundPlayerCallback callback, {
    required List<Float32List> data,
  }) {
    return invokeMethod(
      callback,
      'feedFloat32',
      {
        'data': data,
      },
    );
  }

  Future<int> feedInt16(
    FlutterSoundPlayerCallback callback, {
    required List<Int16List> data,
  }) {
    List<Uint8List> r = [];
    for (Int16List d in data) {
      var dd = d.buffer;
      var ddd = dd.asUint8List();
      r.add(ddd);
    }
    return invokeMethod(
      callback,
      'feedInt16',
      {
        'data': r,
      },
    );
  }

  @override
  Future<int> stopPlayer(
    FlutterSoundPlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'stopPlayer',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<int> pausePlayer(
    FlutterSoundPlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'pausePlayer',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<int> resumePlayer(
    FlutterSoundPlayerCallback callback,
  ) {
    return invokeMethod(
      callback,
      'resumePlayer',
      Map<String, dynamic>(),
    );
  }

  @override
  Future<int> seekToPlayer(FlutterSoundPlayerCallback callback,
      {Duration? duration}) {
    return invokeMethod(
      callback,
      'seekToPlayer',
      {
        'duration': duration!.inMilliseconds,
      },
    );
  }

  @override
  Future<int> setVolume(FlutterSoundPlayerCallback callback, {double? volume}) {
    return invokeMethod(callback, 'setVolume', {
      'volume': volume,
    });
  }

  @override
  Future<int> setVolumePan(FlutterSoundPlayerCallback callback,
      {double? volume, double? pan}) {
    return invokeMethod(callback, 'setVolumePan', {
      'volume': volume,
      'pan': pan,
    });
  }

  @override
  Future<int> setSpeed(FlutterSoundPlayerCallback callback,
      {required double speed}) {
    return invokeMethod(callback, 'setSpeed', {
      'speed': speed,
    });
  }

  Future<String> getResourcePath(
    FlutterSoundPlayerCallback callback,
  ) {
    return invokeMethodString(
      callback,
      'getResourcePath',
      Map<String, dynamic>(),
    );
  }
}
