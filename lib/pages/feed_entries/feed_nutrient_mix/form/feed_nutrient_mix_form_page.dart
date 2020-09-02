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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:super_green_app/data/api/backend/products/models.dart';
import 'package:super_green_app/data/kv/app_db.dart';
import 'package:super_green_app/main/main_navigator_bloc.dart';
import 'package:super_green_app/pages/feed_entries/entry_params/feed_nutrient_mix.dart';
import 'package:super_green_app/pages/feed_entries/feed_nutrient_mix/form/feed_nutrient_mix_form_bloc.dart';
import 'package:super_green_app/widgets/feed_form/feed_form_layout.dart';
import 'package:super_green_app/widgets/feed_form/feed_form_param_layout.dart';
import 'package:super_green_app/widgets/feed_form/number_form_param.dart';
import 'package:super_green_app/widgets/fullscreen_loading.dart';

class FeedNutrientMixFormPage extends StatefulWidget {
  @override
  _FeedNutrientMixFormPageState createState() =>
      _FeedNutrientMixFormPageState();
}

class _FeedNutrientMixFormPageState extends State<FeedNutrientMixFormPage> {
  double volume = 10;

  List<NutrientProduct> nutrientProducts = [];
  List<TextEditingController> quantityControllers = [];

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: BlocProvider.of<FeedNutrientMixFormBloc>(context),
      listener: (BuildContext context, FeedNutrientMixFormBlocState state) {
        if (state is FeedNutrientMixFormBlocStateLoaded) {
          setState(() {
            nutrientProducts = [];
            quantityControllers = [];
            for (Product product in state.products) {
              NutrientProduct nutrientProduct = nutrientProducts.singleWhere(
                  (pi) => pi.product.id == product.id,
                  orElse: () => null);
              if (nutrientProduct == null) {
                nutrientProducts.add(
                    NutrientProduct(product: product, quantity: 0, unit: 'g'));
                quantityControllers.add(TextEditingController(text: null));
              } else {
                nutrientProducts.add(nutrientProduct);
                quantityControllers.add(
                    TextEditingController(text: '${nutrientProduct.quantity}'));
              }
            }
          });
        } else if (state is FeedNutrientMixFormBlocStateDone) {
          BlocProvider.of<MainNavigatorBloc>(context)
              .add(MainNavigatorActionPop(mustPop: true));
        }
      },
      child: BlocBuilder<FeedNutrientMixFormBloc, FeedNutrientMixFormBlocState>(
          cubit: BlocProvider.of<FeedNutrientMixFormBloc>(context),
          builder: (BuildContext context, FeedNutrientMixFormBlocState state) {
            Widget body;
            if (state is FeedNutrientMixFormBlocStateLoading) {
              body = FullscreenLoading(
                title: 'Saving..',
              );
            } else if (state is FeedNutrientMixFormBlocStateInit) {
              body = FullscreenLoading(
                title: 'Loading..',
              );
            } else if (state is FeedNutrientMixFormBlocStateLoaded) {
              body = renderBody(context, state);
            }
            return FeedFormLayout(
                title: '🧪',
                changed: true,
                valid: true,
                onOK: () => BlocProvider.of<FeedNutrientMixFormBloc>(context)
                    .add(FeedNutrientMixFormBlocEventCreate(
                        volume, nutrientProducts)),
                body: AnimatedSwitcher(
                  child: body,
                  duration: Duration(milliseconds: 200),
                ));
          }),
    );
  }

  Widget renderBody(
      BuildContext context, FeedNutrientMixFormBlocStateLoaded state) {
    bool freedomUnits = AppDB().getAppData().freedomUnits == true;
    List<Widget> children = [
      NumberFormParam(
        icon: 'assets/feed_form/icon_volume.svg',
        title: 'Water quantity',
        value: volume,
        step: 1,
        displayMultiplier: freedomUnits ? 0.25 : 1,
        unit: freedomUnits ? ' gal' : ' L',
        onChange: (newValue) {
          setState(() {
            if (newValue > 0) {
              volume = newValue;
            }
          });
        },
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              'Nutrients in your toolbox',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ];
    if (nutrientProducts.length > 0) {
      int i = 0;
      for (NutrientProduct productIntake in nutrientProducts) {
        int index = i;
        children.add(FeedFormParamLayout(
            child:
                renderFertilizer(context, productIntake, quantityControllers[i],
                    (NutrientProduct newProductIntake) {
              setState(() {
                nutrientProducts[index] = newProductIntake;
              });
            }),
            icon: 'assets/products/toolbox/icon_fertilizer.svg',
            title: productIntake.product.name));
        ++i;
      }
    } else {
      children.add(Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                        'assets/products/toolbox/toolbox.svg',
                        width: 110,
                        height: 110),
                  ),
                  Text(
                      'No nutrients in your toolbox yet.\nGo back to the previous screen to add toolbox items.',
                      textAlign: TextAlign.center),
                ],
              ))
            ],
          )));
    }
    return ListView(
      children: children,
    );
  }

  Widget renderFertilizer(
      BuildContext context,
      NutrientProduct productIntake,
      TextEditingController textEditingController,
      Function(NutrientProduct) onChange) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Solid'),
              Switch(
                onChanged: (bool value) {
                  onChange(
                      productIntake.copyWith(unit: value == true ? 'mL' : 'g'));
                },
                value: productIntake.unit == 'mL',
              ),
              Text('Liquid'),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                width: 70,
                child: TextField(
                  decoration: InputDecoration(hintText: 'ex: 10'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: textEditingController,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                  onChanged: (String value) {
                    onChange(
                        productIntake.copyWith(quantity: double.parse(value)));
                  },
                ),
              ),
            ),
            Text(productIntake.unit,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ]),
        ],
      ),
    );
  }
}
