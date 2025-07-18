/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
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

import 'package:logger/logger.dart' show Level;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'method_channel_flutter_sound_recorder.dart';
import 'flutter_sound_platform_interface.dart';
import 'dart:core';
import 'dart:typed_data';

enum RecorderState {
  isStopped,
  isPaused,
  isRecording,
}

/// @nodoc
abstract class FlutterSoundRecorderCallback {
  void updateRecorderProgress({int? duration, double? dbPeakLevel});
  void interleavedRecording({required Uint8List data});
  void recordingDataFloat32({required List<Float32List> data});
  void recordingDataInt16({required List<Int16List> data});
  void startRecorderCompleted(int? state, bool? success);
  void pauseRecorderCompleted(int? state, bool? success);
  void resumeRecorderCompleted(int? state, bool? success);
  void stopRecorderCompleted(int? state, bool? success, String? url);
  void openRecorderCompleted(int? state, bool? success);
  void log(Level logLevel, String msg);
  Duration getSubscriptionDuration();
}

/// The interface that implementations of url_launcher must implement.
///
/// Platform implementations should extend this class rather than implement it as `url_launcher`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [FlutterSoundPlatform] methods.
abstract class FlutterSoundRecorderPlatform extends PlatformInterface {
  /// Constructs a UrlLauncherPlatform.
  FlutterSoundRecorderPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterSoundRecorderPlatform _instance =
      MethodChannelFlutterSoundRecorder();

  /// The default instance of [FlutterSoundRecorderPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterSoundRecorder].
  static FlutterSoundRecorderPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UrlLauncherPlatform] when they register themselves.
  static set instance(FlutterSoundRecorderPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  List<FlutterSoundRecorderCallback?> _slots = [];

  //@override
  int findSession(FlutterSoundRecorderCallback aSession) {
    for (var i = 0; i < _slots.length; ++i) {
      if (_slots[i] == aSession) {
        return i;
      }
    }
    return -1;
  }

  //@override
  void openSession(FlutterSoundRecorderCallback aSession) {
    assert(findSession(aSession) == -1);

    for (var i = 0; i < _slots.length; ++i) {
      if (_slots[i] == null) {
        _slots[i] = aSession;
        return;
      }
    }
    _slots.add(aSession);
  }

  //@override
  void closeSession(FlutterSoundRecorderCallback aSession) {
    _slots[findSession(aSession)] = null;
  }

  FlutterSoundRecorderCallback? getSession(int slotno) {
    return _slots[slotno];
  }

  // ------------------------------------------------------------------------------

  Future<bool> initPlugin() {
    throw UnimplementedError('initPlugin() has not been implemented.');
  }

  Future<void>? setLogLevel(
      FlutterSoundRecorderCallback callback, Level loglevel) {
    throw UnimplementedError('setLogLeve() has not been implemented.');
  }

  Future<void>? resetPlugin(
    FlutterSoundRecorderCallback callback,
  ) {
    throw UnimplementedError('resetPlugin() has not been implemented.');
  }

  Future<void> openRecorder(
    FlutterSoundRecorderCallback callback, {
    required Level logLevel,
  }) {
    throw UnimplementedError('openRecorder() has not been implemented.');
  }

  Future<void> closeRecorder(
    FlutterSoundRecorderCallback callback,
  ) {
    throw UnimplementedError('closeRecorder() has not been implemented.');
  }

  Future<bool> isEncoderSupported(
    FlutterSoundRecorderCallback callback, {
    required Codec codec,
  }) {
    throw UnimplementedError('isEncoderSupported() has not been implemented.');
  }

  Future<void> setSubscriptionDuration(
    FlutterSoundRecorderCallback callback, {
    Duration? duration,
  }) {
    throw UnimplementedError(
        'setSubscriptionDuration() has not been implemented.');
  }

  Future<void> startRecorder(
    FlutterSoundRecorderCallback callback, {
    Codec? codec,
    String? path,
    int sampleRate = 44100,
    int numChannels = 1,
    int bitRate = 16000,
    int bufferSize = 8192,
    Duration timeSlice = Duration.zero,
    bool enableVoiceProcessing = false,
    bool interleaved = true,
    required bool toStream,
    AudioSource? audioSource,
    bool enableNoiseSuppression = false,
    bool enableEchoCancellation = true,
  }) {
    throw UnimplementedError('startRecorder() has not been implemented.');
  }

  Future<void> stopRecorder(
    FlutterSoundRecorderCallback callback,
  ) {
    throw UnimplementedError('stopRecorder() has not been implemented.');
  }

  int getSampleRate(
    FlutterSoundRecorderCallback callback,
  );

  void requestData(
    FlutterSoundRecorderCallback callback,
  );

  Future<void> pauseRecorder(
    FlutterSoundRecorderCallback callback,
  ) {
    throw UnimplementedError('pauseRecorder() has not been implemented.');
  }

  Future<void> resumeRecorder(
    FlutterSoundRecorderCallback callback,
  ) {
    throw UnimplementedError('resumeRecorder() has not been implemented.');
  }

  Future<bool?> deleteRecord(
      FlutterSoundRecorderCallback callback, String path) {
    throw UnimplementedError('deleteRecord() has not been implemented.');
  }

  Future<String?> getRecordURL(
      FlutterSoundRecorderCallback callback, String path) {
    throw UnimplementedError('getRecordURL() has not been implemented.');
  }

  RecorderState get recorderState {
    throw UnimplementedError('getRecordURL() has not been implemented.');
  }
}
