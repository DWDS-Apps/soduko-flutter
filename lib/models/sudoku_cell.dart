import 'dart:convert';

class SudokuCell {
  final int row;
  final int col;
  int value; // 0 = empty
  bool isGiven;
  bool isConflicting;
  Set<int> notes;
  bool isHint;

  SudokuCell({
    required this.row,
    required this.col,
    this.value = 0,
    this.isGiven = false,
    this.isConflicting = false,
    Set<int>? notes,
    this.isHint = false,
  }) : notes = notes ?? {};

  bool get isEmpty => value == 0;
  bool get hasValue => value != 0;
  bool get hasNotes => notes.isNotEmpty;

  SudokuCell copy() {
    return SudokuCell(
      row: row,
      col: col,
      value: value,
      isGiven: isGiven,
      isConflicting: isConflicting,
      notes: Set.from(notes),
      isHint: isHint,
    );
  }

  Map<String, dynamic> toJson() => {
        'row': row,
        'col': col,
        'value': value,
        'isGiven': isGiven,
        'notes': notes.toList(),
      };

  factory SudokuCell.fromJson(Map<String, dynamic> json) {
    return SudokuCell(
      row: json['row'] as int,
      col: json['col'] as int,
      value: json['value'] as int? ?? 0,
      isGiven: json['isGiven'] as bool? ?? false,
      notes: (json['notes'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toSet() ??
          {},
    );
  }
}
