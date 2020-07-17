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

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:super_green_app/data/kv/app_db.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/forms/plant_infos_dimensions.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/forms/plant_infos_medium.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/forms/plant_infos_phase_since.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/forms/plant_infos_plant_type.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/forms/plant_infos_strain.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/plant_infos_bloc.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/plant_infos/widgets/plant_infos_widget.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/settings/box_settings.dart';
import 'package:super_green_app/pages/feeds/plant_feeds/common/settings/plant_settings.dart';
import 'package:super_green_app/widgets/fullscreen_loading.dart';

class PlantInfosPage<PIBloc extends Bloc<PlantInfosEvent, PlantInfosState>>
    extends StatefulWidget {
  PlantInfosPage({Key key}) : super(key: key);

  @override
  _PlantInfosPageState<PIBloc> createState() => _PlantInfosPageState<PIBloc>();
}

class _PlantInfosPageState<
        PIBloc extends Bloc<PlantInfosEvent, PlantInfosState>>
    extends State<PlantInfosPage<PIBloc>> {
  String form;
  ScrollController infosScrollController;

  @override
  void initState() {
    infosScrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PIBloc, PlantInfosState>(
        bloc: BlocProvider.of<PIBloc>(context),
        builder: (BuildContext context, PlantInfosState state) {
          if (state is PlantInfosStateLoading) {
            return _renderLoading(context, state);
          }
          if (form == null) {
            return _renderLoaded(context, state);
          } else {
            return Stack(
              children: <Widget>[
                _renderLoaded(context, state),
                _renderForm(context, state),
              ],
            );
          }
        });
  }

  Widget _renderLoading(BuildContext context, PlantInfosStateLoading state) {
    return FullscreenLoading(
      title: "Loading plant data",
    );
  }

  Widget _renderLoaded(BuildContext context, PlantInfosStateLoaded state) {
    String strain;

    if (state.plantInfos.plantSettings.strain != null &&
        state.plantInfos.plantSettings.seedbank != null) {
      strain =
          '# ${state.plantInfos.plantSettings.strain}\nfrom **${state.plantInfos.plantSettings.seedbank}**';
    } else if (state.plantInfos.plantSettings.strain != null) {
      strain = '# ${state.plantInfos.plantSettings.strain}';
    }

    String format =
        AppDB().getAppData().freedomUnits ? 'MM/dd/yyyy' : 'dd/MM/yyyy';
    String phaseTitle = 'Current phase';
    String phaseSince;
    if (state.plantInfos.plantSettings.phase == 'VEG') {
      if (state.plantInfos.plantSettings.veggingStart != null) {
        phaseSince = DateFormat(format)
            .format(state.plantInfos.plantSettings.veggingStart);
      }
      phaseTitle = 'Vegging since';
    } else if (state.plantInfos.plantSettings.phase == 'BLOOM') {
      if (state.plantInfos.plantSettings.bloomingStart != null) {
        phaseSince = DateFormat(format)
            .format(state.plantInfos.plantSettings.bloomingStart);
      }
      phaseTitle = 'Blooming since';
    }

    String dimensions;
    if (state.plantInfos.boxSettings.width != null &&
        state.plantInfos.boxSettings.height != null &&
        state.plantInfos.boxSettings.depth != null) {
      dimensions =
          '${state.plantInfos.boxSettings.width}x${state.plantInfos.boxSettings.height}x${state.plantInfos.boxSettings.depth}';
    }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ListView(
                  controller: infosScrollController,
                  key: const PageStorageKey<String>('infos'),
                  children: [
                    PlantInfosWidget(
                        title: 'Strain name',
                        value: strain,
                        onEdit: state.plantInfos.editable == false
                            ? null
                            : () => _openForm('STRAIN')),
                    PlantInfosWidget(
                        icon: 'icon_plant_type.svg',
                        title: 'Plant type',
                        value: state.plantInfos.plantSettings.plantType,
                        onEdit: state.plantInfos.editable == false
                            ? null
                            : () => _openForm('PLANT_TYPE')),
                    PlantInfosWidget(
                        icon: 'icon_vegging_since.svg',
                        title: phaseTitle,
                        value: phaseSince,
                        onEdit: state.plantInfos.editable == false
                            ? null
                            : () => _openForm('PHASE_SINCE')),
                    PlantInfosWidget(
                        icon: 'icon_medium.svg',
                        title: 'Medium',
                        value: state.plantInfos.plantSettings.medium,
                        onEdit: state.plantInfos.editable == false
                            ? null
                            : () => _openForm('MEDIUM')),
                    PlantInfosWidget(
                        icon: 'icon_dimension.svg',
                        title: 'Dimensions',
                        value: dimensions,
                        onEdit: state.plantInfos.editable == false
                            ? null
                            : () => _openForm('DIMENSIONS')),
                  ]),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 30.0),
            child: state.plantInfos.thumbnailPath == null
                ? _renderNoPicture(context, state)
                : _renderPicture(context, state),
          )),
        ],
      ),
    );
  }

  Widget _renderNoPicture(BuildContext context, PlantInfosStateLoaded state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text('No picture yet', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _renderPicture(BuildContext context, PlantInfosStateLoaded state) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight - 100,
          child: state.plantInfos.thumbnailPath.startsWith("http")
              ? Image.network(
                  state.plantInfos.thumbnailPath,
                  fit: BoxFit.contain,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return FullscreenLoading(
                        percent: loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes);
                  },
                )
              : Image.file(File(state.plantInfos.thumbnailPath),
                  fit: BoxFit.contain));
    });
  }

  Widget _renderForm(BuildContext context, PlantInfosStateLoaded state) {
    final forms = {
      'STRAIN': () => PlantInfosStrain(
            strain: state.plantInfos.plantSettings.strain,
            seedbank: state.plantInfos.plantSettings.seedbank,
            onCancel: () => _openForm(null),
            onSubmit: (String strain, String seedbank) => updatePlantSettings(
                context,
                state,
                state.plantInfos.plantSettings
                    .copyWith(strain: strain, seedbank: seedbank)),
          ),
      'PLANT_TYPE': () => PlantInfosPlantType(
            plantType: state.plantInfos.plantSettings.plantType,
            onCancel: () => _openForm(null),
            onSubmit: (String plantType) => updatePlantSettings(context, state,
                state.plantInfos.plantSettings.copyWith(plantType: plantType)),
          ),
      'PHASE_SINCE': () => PlantInfosPhaseSince(
          phase: state.plantInfos.plantSettings.phase,
          date: state.plantInfos.plantSettings.veggingStart,
          onCancel: () => _openForm(null),
          onSubmit: (String phase, DateTime date) => updatePlantSettings(
              context,
              state,
              phase == 'VEG'
                  ? state.plantInfos.plantSettings
                      .copyWith(phase: phase, veggingStart: date)
                  : state.plantInfos.plantSettings
                      .copyWith(phase: phase, bloomingStart: date))),
      'MEDIUM': () => PlantInfosMedium(
            medium: state.plantInfos.plantSettings.medium,
            onCancel: () => _openForm(null),
            onSubmit: (String medium) => updatePlantSettings(context, state,
                state.plantInfos.plantSettings.copyWith(medium: medium)),
          ),
      'DIMENSIONS': () => PlantInfosDimensions(
            width: state.plantInfos.boxSettings.width,
            height: state.plantInfos.boxSettings.height,
            depth: state.plantInfos.boxSettings.depth,
            onCancel: () => _openForm(null),
            onSubmit: (int width, int height, int depth) => updateBoxSettings(
                context,
                state,
                state.plantInfos.boxSettings
                    .copyWith(width: width, height: height, depth: depth)),
          ),
    };
    return Container(
      color: Color(0xff063047).withAlpha(127),
      child: Column(
        children: <Widget>[
          Center(
              child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
                decoration: BoxDecoration(
                    color: Color(0xff063047),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.white)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: forms[form](),
                )),
          )),
        ],
      ),
    );
  }

  void _openForm(String form) {
    setState(() {
      this.form = form;
    });
  }

  void updatePlantSettings(BuildContext context, PlantInfosStateLoaded state,
      PlantSettings settings) {
    updatePlantInfos(
        context,
        state.plantInfos.copyWith(
          plantSettings: settings,
        ));
  }

  void updateBoxSettings(
      BuildContext context, PlantInfosStateLoaded state, BoxSettings settings) {
    updatePlantInfos(
        context,
        state.plantInfos.copyWith(
          boxSettings: settings,
        ));
  }

  void updatePlantInfos(BuildContext context, PlantInfos plantInfos) {
    BlocProvider.of<PIBloc>(context).add(PlantInfosEventUpdate(plantInfos));
    _openForm(null);
  }
}