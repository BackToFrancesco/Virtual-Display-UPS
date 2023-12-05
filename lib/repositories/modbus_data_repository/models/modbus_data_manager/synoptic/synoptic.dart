import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Synoptic extends Equatable {
  final AssetImage? maint;
  final Color rectifierInput;
  final AssetImage rectifier;
  final Color dcBus;
  final Color? dcInput;
  final AssetImage? battery;
  final String? m022;
  final String? m024;
  final String? m015;
  final AssetImage? chargeOrDischargeBattery;
  final Color? dcOutput;
  final Color invInput;
  final AssetImage inverter;
  final Color invOutput;
  final Color output;
  final AssetImage? load;
  final String? m000;
  final String? m005;
  final Color? bypOutput;
  final AssetImage? bypass;
  final Color? bypInput;
  final Color? onMntByp;
  final bool noBypass;

  const Synoptic(
      this.maint,
      this.rectifierInput,
      this.rectifier,
      this.dcBus,
      this.dcInput,
      this.battery,
      this.m022,
      this.m024,
      this.m015,
      this.chargeOrDischargeBattery,
      this.dcOutput,
      this.invInput,
      this.inverter,
      this.invOutput,
      this.output,
      this.load,
      this.m000,
      this.m005,
      this.bypOutput,
      this.bypass,
      this.bypInput,
      this.onMntByp,
      this.noBypass);

  Synoptic copyWith(
      {AssetImage? maint,
      Color? rectifierInput,
      AssetImage? rectifier,
      Color? dcBus,
      Color? dcInput,
      AssetImage? battery,
      String? m022,
      String? m024,
      String? m015,
      AssetImage? chargeOrDischargeBattery,
      Color? dcOutput,
      Color? invInput,
      AssetImage? inverter,
      Color? invOutput,
      Color? output,
      AssetImage? load,
      String? m000,
      String? m005,
      Color? bypOutput,
      AssetImage? bypass,
      Color? bypInput,
      Color? onMntByp,
      bool? noBypass}) {
    return Synoptic(
        maint,
        rectifierInput ?? this.rectifierInput,
        rectifier ?? this.rectifier,
        dcBus ?? this.dcBus,
        dcInput ?? this.dcInput,
        battery ?? this.battery,
        m022 ?? this.m022,
        m024 ?? this.m024,
        m015 ?? this.m015,
        chargeOrDischargeBattery ?? this.chargeOrDischargeBattery,
        dcOutput ?? this.dcOutput,
        invInput ?? this.invInput,
        inverter ?? this.inverter,
        invOutput ?? this.invOutput,
        output ?? this.output,
        load ?? this.load,
        m000 ?? this.m000,
        m005 ?? this.m005,
        bypOutput ?? this.bypOutput,
        bypass ?? this.bypass,
        bypInput ?? this.bypInput,
        onMntByp ?? this.onMntByp,
        this.noBypass);
  }

  @override
  List<Object?> get props => [
        maint,
        rectifierInput,
        rectifier,
        dcBus,
        dcInput,
        battery,
        m022,
        m024,
        m015,
        chargeOrDischargeBattery,
        dcOutput,
        invInput,
        inverter,
        invOutput,
        output,
        load,
        m000,
        m005,
        bypOutput,
        bypass,
        bypInput,
        onMntByp,
        noBypass
      ];
}
