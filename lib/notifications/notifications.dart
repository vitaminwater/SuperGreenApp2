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

import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_green_app/data/kv/app_db.dart';
import 'package:super_green_app/data/logger/logger.dart';
import 'package:super_green_app/data/rel/rel_db.dart';
import 'package:super_green_app/main/main_navigator_bloc.dart';
import 'package:super_green_app/notifications/local_notifications.dart';
import 'package:super_green_app/notifications/model.dart';
import 'package:super_green_app/notifications/remote_notifications.dart';
import 'package:super_green_app/pages/home/home_navigator_bloc.dart';

abstract class NotificationsBlocEvent extends Equatable {}

class NotificationsBlocEventInit extends NotificationsBlocEvent {
  @override
  List<Object> get props => [];
}

class NotificationsBlocEventReminder extends NotificationsBlocEvent {
  final int id;
  final int afterMinutes;
  final String title;
  final String body;
  final String payload;

  NotificationsBlocEventReminder(
      this.id, this.afterMinutes, this.title, this.body, this.payload);

  @override
  List<Object> get props => [id, afterMinutes, title, body, payload];
}

class NotificationsBlocEventReceived extends NotificationsBlocEvent {
  final NotificationData notificationData;

  NotificationsBlocEventReceived(this.notificationData);

  @override
  List<Object> get props => [
        notificationData,
      ];
}

abstract class NotificationsBlocState extends Equatable {}

class NotificationsBlocStateInit extends NotificationsBlocState {
  @override
  List<Object> get props => [];
}

class NotificationsBlocStateNotification extends NotificationsBlocState {
  final NotificationData notificationData;

  NotificationsBlocStateNotification(this.notificationData);

  @override
  List<Object> get props => [
        notificationData,
      ];
}

class NotificationsBlocStateMainNavigation extends NotificationsBlocState {
  final int rand = Random().nextInt(1 << 32);
  final MainNavigatorEvent mainNavigatorEvent;

  NotificationsBlocStateMainNavigation(this.mainNavigatorEvent);

  @override
  List<Object> get props => [rand, mainNavigatorEvent];
}

class NotificationsBlocStateHomeNavigation extends NotificationsBlocState {
  final int rand = Random().nextInt(1 << 32);
  final HomeNavigatorEvent homeNavigatorEvent;

  NotificationsBlocStateHomeNavigation(this.homeNavigatorEvent);

  @override
  List<Object> get props => [rand, homeNavigatorEvent];
}

class NotificationsBloc
    extends Bloc<NotificationsBlocEvent, NotificationsBlocState> {
  static RemoteNotifications remoteNotifications;
  static LocalNotifications localNotifications;

  NotificationsBloc() : super(NotificationsBlocStateInit()) {
    remoteNotifications = RemoteNotifications(onNotificationData);
    localNotifications = LocalNotifications(onNotificationData);
    add(NotificationsBlocEventInit());
  }

  @override
  Stream<NotificationsBlocState> mapEventToState(
      NotificationsBlocEvent event) async* {
    if (event is NotificationsBlocEventInit) {
      await Future.wait([
        remoteNotifications.init(),
        localNotifications.init(),
      ]);
    } else if (event is NotificationsBlocEventReceived) {
      NotificationData notificationData = event.notificationData;
      if (notificationData is NotificationDataComment) {
        Logger.log(
            'Opening comment for plant ${notificationData.plantID}, entry ${notificationData.feedEntryID}');
        Plant plant = await RelDB.get()
            .plantsDAO
            .getPlantForServerID(notificationData.plantID);
        FeedEntry feedEntry = await RelDB.get()
            .feedsDAO
            .getFeedEntryForServerID(notificationData.feedEntryID);
        if (plant != null && feedEntry != null) {
          AppDB().setLastPlant(plant.id);
          yield NotificationsBlocStateMainNavigation(
              MainNavigateToHomeEvent(plant: plant, feedEntry: feedEntry));
        } else {
          yield NotificationsBlocStateMainNavigation(MainNavigateToPublicPlant(
              notificationData.plantID,
              feedEntryID: notificationData.feedEntryID));
        }
      } else if (notificationData is NotificationDataReminder) {
        yield NotificationsBlocStateNotification(event.notificationData);
        Plant plant =
            await RelDB.get().plantsDAO.getPlant(notificationData.plantID);
        if (plant == null) return;
        AppDB().setLastPlant(notificationData.plantID);
        yield NotificationsBlocStateMainNavigation(
            MainNavigateToHomeEvent(plant: plant));
      }
    } else if (event is NotificationsBlocEventReminder) {
      await localNotifications.reminderNotification(event.id,
          event.afterMinutes, NotificationData.fromJSON(event.payload));
    }
  }

  void onNotificationData(NotificationData notificationData) {
    add(NotificationsBlocEventReceived(notificationData));
  }
}