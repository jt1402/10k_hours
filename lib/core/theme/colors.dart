import 'package:flutter/material.dart';

const seedColor = Color(0xFF14B8A6);

ColorScheme lightScheme([Color seed = seedColor]) =>
    ColorScheme.fromSeed(seedColor: seed);

ColorScheme darkScheme([Color seed = seedColor]) =>
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
