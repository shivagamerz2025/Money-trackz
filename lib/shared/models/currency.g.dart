// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyAdapter extends TypeAdapter<Currency> {
  @override
  final int typeId = 8;

  @override
  Currency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Currency.usd;
      case 1:
        return Currency.inr;
      case 2:
        return Currency.eur;
      case 3:
        return Currency.gbp;
      case 4:
        return Currency.cad;
      case 5:
        return Currency.aud;
      case 6:
        return Currency.jpy;
      case 7:
        return Currency.cny;
      case 8:
        return Currency.sgd;
      case 9:
        return Currency.hkd;
      default:
        return Currency.usd;
    }
  }

  @override
  void write(BinaryWriter writer, Currency obj) {
    switch (obj) {
      case Currency.usd:
        writer.writeByte(0);
        break;
      case Currency.inr:
        writer.writeByte(1);
        break;
      case Currency.eur:
        writer.writeByte(2);
        break;
      case Currency.gbp:
        writer.writeByte(3);
        break;
      case Currency.cad:
        writer.writeByte(4);
        break;
      case Currency.aud:
        writer.writeByte(5);
        break;
      case Currency.jpy:
        writer.writeByte(6);
        break;
      case Currency.cny:
        writer.writeByte(7);
        break;
      case Currency.sgd:
        writer.writeByte(8);
        break;
      case Currency.hkd:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
