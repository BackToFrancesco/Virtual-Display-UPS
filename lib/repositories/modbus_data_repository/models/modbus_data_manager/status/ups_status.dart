import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class UpsStatus extends Equatable {
  final String description;
  final Color color;

  const UpsStatus(this.description, this.color);

  @override
  List<Object> get props => [description, color];
}
