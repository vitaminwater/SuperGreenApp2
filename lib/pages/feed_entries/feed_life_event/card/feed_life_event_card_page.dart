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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_green_app/pages/feed_entries/entry_params/feed_life_event.dart';
import 'package:super_green_app/pages/feeds/feed/bloc/feed_bloc.dart';
import 'package:super_green_app/pages/feeds/feed/bloc/state/feed_entry_state.dart';
import 'package:super_green_app/pages/feeds/feed/bloc/state/feed_state.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_feed_state.dart';
import 'package:super_green_app/widgets/feed_card/feed_card.dart';
import 'package:super_green_app/widgets/feed_card/feed_card_date.dart';
import 'package:super_green_app/widgets/feed_card/feed_card_title.dart';
import 'package:super_green_app/widgets/fullscreen_loading.dart';

class FeedLifeEventCardPage extends StatelessWidget {
  final Animation animation;
  final FeedState feedState;
  final FeedEntryState state;

  const FeedLifeEventCardPage(this.animation, this.feedState, this.state,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state is FeedEntryStateLoaded && feedState is PlantFeedState) {
      return _renderLoaded(context, state, feedState);
    }
    return _renderLoading(context, state);
  }

  Widget _renderLoading(BuildContext context, FeedEntryState state) {
    return FeedCard(
      animation: animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeedCardTitle('assets/feed_card/icon_life_events.svg', 'Life Event',
              state.synced,
              showSyncStatus: !state.remoteState,
              showControls: !state.remoteState),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FeedCardDate(state, feedState),
          ),
          Container(
            height: 100,
            alignment: Alignment.center,
            child: FullscreenLoading(),
          ),
        ],
      ),
    );
  }

  Widget _renderLoaded(BuildContext context, FeedEntryStateLoaded state,
      PlantFeedState feedState) {
    FeedLifeEventParams params = state.params;
    const List<String> phases = [
      'Germination!',
      'Vegging Started!',
      'Blooming Started!',
      'Drying Started!',
      'Curing Started!'
    ];
    return FeedCard(
      animation: animation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeedCardTitle(
            'assets/feed_card/icon_life_events.svg',
            'Life Event',
            state.synced,
            showSyncStatus: !state.remoteState,
            showControls: !state.remoteState,
            onDelete: () {
              BlocProvider.of<FeedBloc>(context)
                  .add(FeedBlocEventDeleteEntry(state));
            },
          ),
          Container(
            height: 130,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(phases[params.phase.index],
                  style: TextStyle(
                      color: Color(0xff3bb30b),
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FeedCardDate(state, feedState),
          ),
        ],
      ),
    );
  }

  List<Widget> _renderValues(
      List<dynamic> values, List<dynamic> initialValues) {
    int i = 0;
    return values
        .map<Map<String, int>>((v) {
          return {
            'i': i,
            'from': initialValues[i++],
            'to': v,
          };
        })
        .where((v) => v['from'] != v['to'])
        .map<Widget>((v) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('channel'),
                    Text('${v['i'] + 1}',
                        style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('${v['from']}%',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300)),
                    Icon(Icons.arrow_forward, size: 18),
                    Text('${v['to']}%',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.green)),
                  ],
                ),
              ],
            ),
          );
        })
        .toList();
  }
}
