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

import 'package:equatable/equatable.dart';
import 'package:super_green_app/data/api/backend/products/models.dart';

const DEFAULT_SCHEDULES = {
  'VEG': {
    'ON_HOUR': 3,
    'ON_MIN': 0,
    'OFF_HOUR': 21,
    'OFF_MIN': 0,
  },
  'BLOOM': {
    'ON_HOUR': 6,
    'ON_MIN': 0,
    'OFF_HOUR': 18,
    'OFF_MIN': 0,
  },
  'AUTO': {
    'ON_HOUR': 0,
    'ON_MIN': 0,
    'OFF_HOUR': 0,
    'OFF_MIN': 0,
  },
};

class BoxSettings extends Equatable {
  final String schedule;
  final Map<String, dynamic> schedules;

  final int width;
  final int height;
  final int depth;
  final String unit;

  final List<Product> products;

  BoxSettings(
      {this.width,
      this.height,
      this.depth,
      this.unit,
      this.schedule = 'VEG',
      this.schedules = DEFAULT_SCHEDULES,
      this.products});

  factory BoxSettings.fromMap(Map<String, dynamic> map) {
    List<dynamic> products = map['products'] ?? [];
    return BoxSettings(
      width: map['width'],
      height: map['height'],
      depth: map['depth'],
      unit: map['unit'],
      schedule: map['schedule'] ?? 'VEG',
      schedules: map['schedules'] ?? DEFAULT_SCHEDULES,
      products: products.map<Product>((p) => Product.fromMap(p)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schedule': schedule,
      'schedules': schedules,
      'width': width,
      'height': height,
      'depth': depth,
      'unit': unit,
      'products': products.map((p) => p.toMap()).toList(),
    };
  }

  factory BoxSettings.fromJSON(String json) {
    Map<String, dynamic> map = JsonDecoder().convert(json);
    return BoxSettings.fromMap(map);
  }

  String toJSON() {
    return JsonEncoder().convert(toMap());
  }

  @override
  List<Object> get props =>
      [schedule, schedules, width, height, depth, unit, products];

  BoxSettings copyWith({
    String schedule,
    Map<String, dynamic> schedules,
    int width,
    int height,
    int depth,
    String unit,
    List<Product> products,
  }) =>
      BoxSettings(
        width: width ?? this.width,
        height: height ?? this.height,
        depth: depth ?? this.depth,
        unit: unit ?? this.unit,
        schedule: schedule ?? this.schedule,
        schedules: schedules ?? this.schedules,
        products: products ?? this.products,
      );
}
