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

import 'dart:convert';

import 'package:moor/moor.dart';
import 'package:super_green_app/data/local/feed_entry_helper.dart';
import 'package:super_green_app/data/rel/feed/feeds.dart';
import 'package:super_green_app/data/rel/rel_db.dart';
import 'package:super_green_app/pages/feed_entries/common/media_state.dart';
import 'package:super_green_app/pages/feed_entries/entry_params/feed_entry_params.dart';
import 'package:super_green_app/pages/feed_entries/feed_care/feed_care_common/card/feed_care_common_state.dart';
import 'package:super_green_app/pages/feeds/feed/bloc/feed_bloc.dart';
import 'package:super_green_app/pages/feeds/feed/bloc/local/loaders/local_feed_entry_loader.dart';
import 'package:super_green_app/pages/feeds/feed/bloc/state/feed_entry_state.dart';

class FeedCareLoader extends LocalFeedEntryLoader {
  FeedCareLoader(Function(FeedBlocEvent) add) : super(add);

  @override
  Future<FeedEntryStateLoaded> load(FeedEntryStateNotLoaded state) async {
    List<FeedMedia> medias =
        await RelDB.get().feedsDAO.getFeedMedias(state.feedEntryID);
    List<MediaState> beforeMedias = medias
        .where((m) {
          final Map<String, dynamic> params = JsonDecoder().convert(m.params);
          return params['before'];
        })
        .map<MediaState>((m) => MediaState(
            m.id,
            FeedMedias.makeAbsoluteFilePath(m.filePath),
            FeedMedias.makeAbsoluteFilePath(m.thumbnailPath),
            m.synced))
        .toList();
    List<MediaState> afterMedias = medias
        .where((m) {
          final Map<String, dynamic> params = JsonDecoder().convert(m.params);
          return !params['before'];
        })
        .map<MediaState>((m) => MediaState(
            m.id,
            FeedMedias.makeAbsoluteFilePath(m.filePath),
            FeedMedias.makeAbsoluteFilePath(m.thumbnailPath),
            m.synced))
        .toList();
    return FeedCareCommonState(state, beforeMedias, afterMedias);
  }

  @override
  Future update(FeedEntryState entry, FeedEntryParams params) async {
    await FeedEntryHelper.updateFeedEntry(FeedEntriesCompanion(
        id: Value(entry.feedEntryID),
        params: Value(params.toJSON()),
        synced: Value(false)));
  }

  @override
  Future<void> close() async {}
}
