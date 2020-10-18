/*
 * Copyright (C) 2018  SuperGreenLab <towelie@supergreenlab.com>
 * Author: Constantin Clauzel <constantin.clauzel@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_green_app/device_daemon/device_daemon_bloc.dart';
import 'package:super_green_app/main/main_navigator_bloc.dart';
import 'package:super_green_app/pages/feed_entries/feed_ventilation/form/feed_ventilation_form_bloc.dart';
import 'package:super_green_app/pages/feed_entries/feed_ventilation/form/feed_ventilation_legacy_form_page.dart';
import 'package:super_green_app/pages/feed_entries/feed_ventilation/form/feed_ventilation_v3_form_page.dart';
import 'package:super_green_app/widgets/feed_form/feed_form_layout.dart';
import 'package:super_green_app/widgets/fullscreen.dart';
import 'package:super_green_app/widgets/fullscreen_loading.dart';
import 'package:super_green_app/widgets/green_button.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedVentilationFormPage extends StatefulWidget {
  @override
  _FeedVentilationFormPageState createState() =>
      _FeedVentilationFormPageState();
}

class _FeedVentilationFormPageState extends State<FeedVentilationFormPage> {
  bool _reachable = true;
  bool _usingWifi = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: BlocProvider.of<FeedVentilationFormBloc>(context),
      listener: (BuildContext context, FeedVentilationFormBlocState state) {
        if (state is FeedVentilationFormBlocStateLoaded) {
          if (state.box.device != null) {
            Timer(Duration(milliseconds: 100), () {
              BlocProvider.of<DeviceDaemonBloc>(context)
                  .add(DeviceDaemonBlocEventLoadDevice(state.box.device));
            });
          }
        } else if (state is FeedVentilationFormBlocStateDone) {
          BlocProvider.of<MainNavigatorBloc>(context)
              .add(MainNavigatorActionPop(mustPop: true));
        }
      },
      child: BlocBuilder<FeedVentilationFormBloc, FeedVentilationFormBlocState>(
          cubit: BlocProvider.of<FeedVentilationFormBloc>(context),
          builder: (context, state) {
            Widget body;
            if (state is FeedVentilationFormBlocStateLoading) {
              body = FullscreenLoading(title: state.text);
            } else if (state is FeedVentilationFormBlocStateLoaded &&
                state.noDevice == true) {
              body = Stack(
                children: <Widget>[
                  _renderParams(context, state),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white60),
                    child: Fullscreen(
                      title: 'Ventilation control\nrequires an SGL controller',
                      child: Column(
                        children: <Widget>[
                          GreenButton(
                            title: 'SHOP NOW',
                            onPressed: () {
                              launch('https://www.supergreenlab.com');
                            },
                          ),
                          Text('or'),
                          GreenButton(
                            title: 'DIY NOW',
                            onPressed: () {
                              launch('https://github.com/supergreenlab');
                            },
                          ),
                        ],
                      ),
                      childFirst: false,
                    ),
                  ),
                ],
              );
            } else if (state is FeedVentilationFormBlocStateLoaded) {
              Widget content = _renderParams(context, state);
              if (_reachable == false) {
                String title = 'Looking for device..';
                if (_usingWifi == false) {
                  title =
                      'Device unreachable!\n(You\'re not connected to any wifi)';
                }
                content = Stack(
                  children: <Widget>[
                    content,
                    Fullscreen(
                        title: title,
                        backgroundColor: Colors.white54,
                        child: _usingWifi == false
                            ? Icon(Icons.error, color: Colors.red, size: 100)
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator()),
                              )),
                  ],
                );
              }
              body = BlocListener<DeviceDaemonBloc, DeviceDaemonBlocState>(
                  listener: (BuildContext context,
                      DeviceDaemonBlocState daemonState) {
                    if (daemonState is DeviceDaemonBlocStateDeviceReachable &&
                        daemonState.device.id == state.box.device) {
                      if (_reachable == daemonState.reachable &&
                          _usingWifi == daemonState.usingWifi) return;
                      setState(() {
                        _reachable = daemonState.reachable;
                        _usingWifi = daemonState.usingWifi;
                      });
                    }
                  },
                  child: content);
            }
            bool changed = state is FeedVentilationFormBlocStateLoaded &&
                (state.blowerMin?.isChanged == true ||
                    state.blowerMax?.isChanged == true ||
                    state.blowerRefMin?.isChanged == true ||
                    state.blowerRefMax?.isChanged == true ||
                    state.blowerRefSource?.isChanged == true ||
                    state.blowerDay?.isChanged == true ||
                    state.blowerNight?.isChanged == true);
            return FeedFormLayout(
                title: '💨',
                fontSize: 35,
                changed: changed,
                valid: changed && _reachable,
                hideBackButton: ((_reachable == false && changed) ||
                    state is FeedVentilationFormBlocStateLoading),
                onOK: () {
                  BlocProvider.of<FeedVentilationFormBloc>(context)
                      .add(FeedVentilationFormBlocEventCreate());
                },
                body: WillPopScope(
                  onWillPop: () async {
                    if (_reachable == false && changed) {
                      return false;
                    }
                    if (state is FeedVentilationFormBlocStateLoaded &&
                        state.noDevice == true) {
                      return true;
                    }
                    if (changed) {
                      BlocProvider.of<FeedVentilationFormBloc>(context)
                          .add(FeedVentilationFormBlocEventCancelEvent());
                      return false;
                    }
                    return true;
                  },
                  child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 200), child: body),
                ));
          }),
    );
  }

  Widget _renderParams(
      BuildContext context, FeedVentilationFormBlocStateLoaded state) {
    if (state.isLegacy) {
      return FeedVentilationLegacyFormPage(state);
    }
    return FeedVentilationV3FormPage(state);
  }
}
