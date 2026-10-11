import 'dart:math';
import '../../data/models.dart';

class QuestionGenerator {
  static final Random _random = Random();
  static final Set<String> _recentSignatures = {};

  static List<GeneratedQuestion> generateQuestions(PracticeConfiguration config) {
    List<GeneratedQuestion> questions = [];
    for (int i = 0; i < config.questionCount; i++) {
      questions.add(generateSingleUniqueQuestion(config, 'q_${DateTime.now().millisecondsSinceEpoch}_$i'));
    }
    return questions;
  }

  static GeneratedQuestion generateSingleUniqueQuestion(PracticeConfiguration config, String id) {
    for (int attempts = 0; attempts < 15; attempts++) {
      GeneratedQuestion q = _generateSingleQuestion(config, id);
      String sig = '${q.category}:${q.displayExpression}';
      if (!_recentSignatures.contains(sig)) {
        _recentSignatures.add(sig);
        if (_recentSignatures.length > 80) {
          _recentSignatures.remove(_recentSignatures.first);
        }
        return q;
      }
    }
    return _generateSingleQuestion(config, id);
  }

  static GeneratedQuestion _generateSingleQuestion(PracticeConfiguration config, String id) {
    String category = config.category;
    if (category == 'Mixed Practice' || category == 'Custom Practice') {
      List<String> pool = config.enabledCategories != null && config.enabledCategories!.isNotEmpty
          ? config.enabledCategories!
          : [
              'Arithmetic',
              'Random Calculations',
              'BODMAS Challenge',
              'Number Series',
              'Inequalities',
              'Mental Maths',
              'Missing Number',
              'Number Puzzles',
            ];
      category = pool[_random.nextInt(pool.length)];
    }

    switch (category) {
      case 'Arithmetic':
      case 'Basic Arithmetic':
        return _generateArithmetic(id, config);
      case 'Random Calculations':
        return _generateRandomCalculations(id, config);
      case 'BODMAS Challenge':
        return _generateBodmas(id, config.difficulty);
      case 'Number Series':
        return _generateNumberSeries(id, config.difficulty);
      case 'Inequalities':
        return _generateInequality(id, config.difficulty);
      case 'Mental Maths':
      case 'Mental Calculation':
        return _generateMentalCalculation(id, config);
      case 'Missing Number':
        return _generateMissingNumber(id, config.difficulty);
      case 'Number Puzzles':
        return _generateNumberPuzzle(id, config.difficulty);
      default:
        return _generateArithmetic(id, config);
    }
  }

  // 1. Arithmetic - guaranteed distinct operands (a != b) & custom operation support
  static GeneratedQuestion _generateArithmetic(String id, PracticeConfiguration config) {
    final difficulty = config.difficulty;
    final operation = config.operation;
    final digits = config.digits;
    final operandsCount = config.operandsCount;

    String op;
    if (operation == 'Addition') {
      op = '+';
    } else if (operation == 'Subtraction') {
      op = '-';
    } else if (operation == 'Multiplication') {
      op = '×';
    } else if (operation == 'Division') {
      op = '÷';
    } else {
      final ops = ['+', '-', '×', '÷'];
      op = ops[_random.nextInt(ops.length)];
    }

    // Determine range by digit configuration
    int minVal;
    int maxVal;
    if (digits == 1) {
      minVal = 2;
      maxVal = 9;
    } else if (digits == 3) {
      minVal = 100;
      maxVal = 499;
    } else {
      // 2-digit default
      minVal = difficulty == 'Hard' ? 15 : (difficulty == 'Medium' ? 10 : 10);
      maxVal = difficulty == 'Hard' ? 99 : (difficulty == 'Medium' ? 75 : 50);
    }

    int answer;
    String expr;
    String explanation;

    if (operandsCount == 3 && (op == '+' || op == '-' || operation == 'Mixed Operations')) {
      // 3-operand arithmetic
      int a = minVal + _random.nextInt(maxVal - minVal + 1);
      int b = minVal + _random.nextInt(maxVal - minVal + 1);
      int c = minVal + _random.nextInt(maxVal - minVal + 1);
      while (b == a) {
        b = minVal + _random.nextInt(maxVal - minVal + 1);
      }
      while (c == a || c == b) {
        c = minVal + _random.nextInt(maxVal - minVal + 1);
      }

      if (op == '-') {
        int total = a + b + c;
        answer = total - a - b;
        expr = '$total - $a - $b = ?';
        explanation = 'Subtract in stages: $total - $a = ${total - a}, then ${total - a} - $b = $answer.';
      } else {
        answer = a + b + c;
        expr = '$a + $b + $c = ?';
        explanation = 'Group friendly numbers: ($a + $b) = ${a + b}, then ${a + b} + $c = $answer.';
      }
    } else if (op == '+') {
      int a = minVal + _random.nextInt(maxVal - minVal + 1);
      int b = minVal + _random.nextInt(maxVal - minVal + 1);
      while (b == a) {
        b = minVal + _random.nextInt(maxVal - minVal + 1);
      }
      answer = a + b;
      expr = '$a + $b = ?';
      explanation = 'Mental shortcut: Break into tens and units: ($a) + ($b) = ${((a ~/ 10) + (b ~/ 10)) * 10} + ${(a % 10) + (b % 10)} = $answer.';
    } else if (op == '-') {
      int a = minVal + _random.nextInt(maxVal - minVal + 1);
      int b = minVal + _random.nextInt(maxVal - minVal + 1);
      while (b == a) {
        b = minVal + _random.nextInt(maxVal - minVal + 1);
      }
      if (a < b) {
        int temp = a; a = b; b = temp;
      }
      answer = a - b;
      expr = '$a - $b = ?';
      explanation = 'Subtract in chunks: $a - ${(b ~/ 10) * 10} = ${a - ((b ~/ 10) * 10)}, then subtract ${b % 10} = $answer.';
    } else if (op == '×') {
      int mulA;
      int mulB;
      if (digits == 1) {
        mulA = _random.nextInt(8) + 2;
        mulB = _random.nextInt(8) + 2;
      } else if (digits == 3) {
        mulA = _random.nextInt(90) + 10;
        mulB = _random.nextInt(80) + 12;
      } else {
        mulA = difficulty == 'Hard' ? (_random.nextInt(15) + 6) : (_random.nextInt(10) + 3);
        mulB = difficulty == 'Hard' ? (_random.nextInt(12) + 4) : (_random.nextInt(9) + 2);
      }
      while (mulB == mulA) {
        mulB = mulB + 1;
      }
      answer = mulA * mulB;
      expr = '$mulA × $mulB = ?';
      explanation = 'Multiplication: $mulA × $mulB = $answer. Mental decomposition: $mulA × ${mulB ~/ 2} × 2.';
    } else {
      // Division
      int divisor = digits == 1 ? (_random.nextInt(7) + 2) : (_random.nextInt(12) + 2);
      int quotient = digits == 1 ? (_random.nextInt(8) + 2) : (_random.nextInt(15) + 2);
      while (quotient == divisor) {
        quotient = quotient + 1;
      }
      int dividend = divisor * quotient;
      answer = quotient;
      expr = '$dividend ÷ $divisor = ?';
      explanation = 'Division is inverse multiplication: $divisor × ? = $dividend. Since $divisor × $quotient = $dividend, the answer is $quotient.';
    }

    return GeneratedQuestion(
      id: id,
      category: config.category,
      questionType: 'arithmetic',
      displayExpression: expr,
      correctAnswer: answer.toString(),
      answerOptions: _generateDistractors(answer),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // 2. Random Calculations - distinct operands
  static GeneratedQuestion _generateRandomCalculations(String id, PracticeConfiguration config) {
    final difficulty = config.difficulty;
    final enabled = config.enabledOperations ?? ['Addition', 'Subtraction', 'Multiplication', 'Squares'];

    int mode = _random.nextInt(3);
    if (enabled.contains('Squares') && !enabled.contains('Percentages') && mode == 1) {
      mode = 0;
    } else if (enabled.contains('Percentages') && !enabled.contains('Squares') && mode == 0) {
      mode = 1;
    }

    if (mode == 0) {
      // Square calculation
      int n = difficulty == 'Hard' ? (_random.nextInt(20) + 15) : (_random.nextInt(15) + 5);
      int answer = n * n;
      String expr = '$n² = ?';
      String explanation = 'Square of $n: $n × $n = $answer. Mental tip: ${(n - 1)} × ${(n + 1)} + 1 = ${(n - 1) * (n + 1)} + 1 = $answer.';
      return GeneratedQuestion(
        id: id,
        category: config.category,
        questionType: 'square',
        displayExpression: expr,
        correctAnswer: answer.toString(),
        answerOptions: _generateDistractors(answer),
        difficulty: difficulty,
        explanation: explanation,
      );
    } else if (mode == 1) {
      // Percentage calculation
      final percents = [10, 20, 25, 50, 75];
      int pct = percents[_random.nextInt(percents.length)];
      int base = (_random.nextInt(10) + 2) * 20;
      int answer = ((pct * base) / 100).round();
      String expr = '$pct% of $base = ?';
      String explanation = '$pct% means $pct/100. For $pct% of $base: 10% is ${(base / 10).round()}, so $pct% is $answer.';
      return GeneratedQuestion(
        id: id,
        category: 'Random Calculations',
        questionType: 'percentage',
        displayExpression: expr,
        correctAnswer: answer.toString(),
        answerOptions: _generateDistractors(answer),
        difficulty: difficulty,
        explanation: explanation,
      );
    } else {
      // 3-operand calculation: a + b - c with all distinct numbers
      int a = _random.nextInt(30) + 10;
      int b = _random.nextInt(30) + 10;
      while (b == a) {
        b = _random.nextInt(30) + 10;
      }
      int c = _random.nextInt(20) + 5;
      while (c == a || c == b) {
        c = _random.nextInt(20) + 5;
      }
      int answer = a + b - c;
      String expr = '$a + $b - $c = ?';
      String explanation = 'Add first: $a + $b = ${a + b}. Then subtract $c: ${a + b} - $c = $answer.';
      return GeneratedQuestion(
        id: id,
        category: 'Random Calculations',
        questionType: 'three_operand',
        displayExpression: expr,
        correctAnswer: answer.toString(),
        answerOptions: _generateDistractors(answer),
        difficulty: difficulty,
        explanation: explanation,
      );
    }
  }

  // 3. BODMAS Challenge - distinct values
  static GeneratedQuestion _generateBodmas(String id, String difficulty) {
    int type = _random.nextInt(3);
    String expr;
    int answer;
    String explanation;

    if (type == 0) {
      // (a + b) × c
      int a = _random.nextInt(10) + 2;
      int b = _random.nextInt(10) + 2;
      while (b == a) {
        b = _random.nextInt(10) + 2;
      }
      int c = _random.nextInt(6) + 2;
      while (c == a || c == b) {
        c = _random.nextInt(6) + 2;
      }
      answer = (a + b) * c;
      expr = '($a + $b) × $c = ?';
      explanation = 'BODMAS rule: Solve brackets first ($a + $b = ${a + b}), then multiply by $c: ${a + b} × $c = $answer.';
    } else if (type == 1) {
      // a + b × c
      int a = _random.nextInt(20) + 5;
      int b = _random.nextInt(8) + 2;
      int c = _random.nextInt(8) + 2;
      while (c == b) {
        c = _random.nextInt(8) + 2;
      }
      answer = a + (b * c);
      expr = '$a + $b × $c = ?';
      explanation = 'BODMAS rule: Multiplication comes before addition! $b × $c = ${b * c}. Then $a + ${b * c} = $answer.';
    } else {
      // a × b - c ÷ d (with clean division and distinct values)
      int d = _random.nextInt(5) + 2;
      int divResult = _random.nextInt(6) + 2;
      while (divResult == d) {
        divResult = _random.nextInt(6) + 2;
      }
      int c = d * divResult;
      int a = _random.nextInt(8) + 2;
      int b = _random.nextInt(6) + 2;
      while (b == a) {
        b = _random.nextInt(6) + 2;
      }
      answer = (a * b) - divResult;
      expr = '$a × $b - $c ÷ $d = ?';
      explanation = 'BODMAS rule: Compute division and multiplication first: ($a × $b = ${a * b}) and ($c ÷ $d = $divResult). Then subtract: ${a * b} - $divResult = $answer.';
    }

    return GeneratedQuestion(
      id: id,
      category: 'BODMAS Challenge',
      questionType: 'bodmas',
      displayExpression: expr,
      correctAnswer: answer.toString(),
      answerOptions: _generateDistractors(answer),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // 4. Number Series - varied patterns
  static GeneratedQuestion _generateNumberSeries(String id, String difficulty) {
    int type = _random.nextInt(4);
    String expr;
    int answer;
    String explanation;

    if (type == 0) {
      // Arithmetic progression (+step)
      int start = _random.nextInt(15) + 3;
      int step = _random.nextInt(7) + 3;
      final seq = [start, start + step, start + 2 * step, start + 3 * step];
      answer = start + 4 * step;
      expr = '${seq.join(", ")}, ?';
      explanation = 'Arithmetic sequence adding +$step each step: ${seq.last} + $step = $answer.';
    } else if (type == 1) {
      // Increasing difference (+2, +4, +6, +8...)
      int start = _random.nextInt(10) + 2;
      int diffStart = _random.nextInt(3) + 2;
      int s0 = start;
      int s1 = s0 + diffStart;
      int s2 = s1 + (diffStart + 2);
      int s3 = s2 + (diffStart + 4);
      answer = s3 + (diffStart + 6);
      expr = '$s0, $s1, $s2, $s3, ?';
      explanation = 'Differences increase by +2 each step (+${diffStart}, +${diffStart + 2}, +${diffStart + 4}, +${diffStart + 6}): $s3 + ${diffStart + 6} = $answer.';
    } else if (type == 2) {
      // Doubling difference (+step, +2*step, +4*step...)
      int start = _random.nextInt(8) + 2;
      int step = _random.nextInt(3) + 2;
      int s0 = start;
      int s1 = s0 + step;
      int s2 = s1 + step * 2;
      int s3 = s2 + step * 4;
      answer = s3 + step * 8;
      expr = '$s0, $s1, $s2, $s3, ?';
      explanation = 'Differences double each step (+${step}, +${step * 2}, +${step * 4}, +${step * 8}): $s3 + ${step * 8} = $answer.';
    } else {
      // Squares sequence
      int start = _random.nextInt(4) + 2;
      final seq = [
        start * start,
        (start + 1) * (start + 1),
        (start + 2) * (start + 2),
        (start + 3) * (start + 3)
      ];
      answer = (start + 4) * (start + 4);
      expr = '${seq.join(", ")}, ?';
      explanation = 'Perfect squares sequence: ${start}², ${start + 1}², ${start + 2}², ${start + 3}², ${start + 4}² = $answer.';
    }

    return GeneratedQuestion(
      id: id,
      category: 'Number Series',
      questionType: 'series',
      displayExpression: expr,
      correctAnswer: answer.toString(),
      answerOptions: _generateDistractors(answer),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // 5. Inequalities - distinct operands
  static GeneratedQuestion _generateInequality(String id, String difficulty) {
    int a = _random.nextInt(22) + 5;
    int b = _random.nextInt(14) + 2;
    while (b == a) {
      b = _random.nextInt(14) + 2;
    }
    int c = _random.nextInt(22) + 5;
    while (c == a || c == b) {
      c = _random.nextInt(22) + 5;
    }
    int d = _random.nextInt(14) + 2;
    while (d == a || d == b || d == c) {
      d = _random.nextInt(14) + 2;
    }

    int left = a + b;
    int right = c + d;

    String answer;
    if (left > right) {
      answer = '>';
    } else if (left < right) {
      answer = '<';
    } else {
      answer = '=';
    }

    String expr = '($a + $b) [ ? ] ($c + $d)';
    String explanation = 'Left side = $a + $b = $left. Right side = $c + $d = $right. Since $left $answer $right, the correct symbol is $answer.';

    return GeneratedQuestion(
      id: id,
      category: 'Inequalities',
      questionType: 'inequality',
      displayExpression: expr,
      correctAnswer: answer,
      answerOptions: ['>', '<', '=', '≠']..shuffle(_random),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // 6. Mental Maths / Calculation (Sequential operations with non-repeating delta)
  static GeneratedQuestion _generateMentalCalculation(String id, PracticeConfiguration config) {
    final difficulty = config.difficulty;
    final mode = config.subType ?? 'Add & Subtract (+/-)';
    int stepCount = config.operandsCount >= 3 ? config.operandsCount : (difficulty == 'Hard' ? 5 : (difficulty == 'Medium' ? 4 : 3));
    int current = _random.nextInt(20) + 15;
    List<String> steps = [current.toString()];
    List<String> stepExplanations = ['Start with $current'];

    int lastVal = -1;
    for (int i = 1; i < stepCount; i++) {
      bool isAdd = mode.contains('Addition only') ? true : _random.nextBool();
      int val = _random.nextInt(12) + 3;
      while (val == lastVal) {
        val = _random.nextInt(12) + 3;
      }
      lastVal = val;

      if (isAdd || (current - val < 5)) {
        current += val;
        steps.add('+ $val');
        stepExplanations.add('Add $val -> $current');
      } else {
        current -= val;
        steps.add('- $val');
        stepExplanations.add('Subtract $val -> $current');
      }
    }

    int answer = current;
    String expr = steps.join(' ');
    String explanation = 'Sequential steps:\n${stepExplanations.join("\n")} -> Final result = $answer.';

    return GeneratedQuestion(
      id: id,
      category: config.category,
      questionType: 'mental',
      displayExpression: expr,
      correctAnswer: answer.toString(),
      answerOptions: _generateDistractors(answer),
      difficulty: difficulty,
      explanation: explanation,
      mentalSteps: steps,
    );
  }

  // 7. Missing Number - distinct numbers
  static GeneratedQuestion _generateMissingNumber(String id, String difficulty) {
    int a = _random.nextInt(32) + 10;
    int b = _random.nextInt(24) + 5;
    while (b == a) {
      b = _random.nextInt(24) + 5;
    }
    int sum = a + b;
    String expr = '$a + ? = $sum';
    String explanation = 'Solve for ?: ? = $sum - $a = $b.';

    return GeneratedQuestion(
      id: id,
      category: 'Missing Number',
      questionType: 'missing',
      displayExpression: expr,
      correctAnswer: b.toString(),
      answerOptions: _generateDistractors(b),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // 8. Number Puzzles - 8 Diverse Mathematical Concepts
  static GeneratedQuestion _generateNumberPuzzle(String id, String difficulty) {
    int conceptType = _random.nextInt(8);
    String expr;
    int answer;
    String explanation;

    switch (conceptType) {
      case 0:
        // Concept 1: x -> x² ± k
        final offsets = [1, 2, 3, -1, -2];
        int k = offsets[_random.nextInt(offsets.length)];
        String sign = k >= 0 ? '+ $k' : '- ${k.abs()}';
        int start = _random.nextInt(4) + 2;
        int e1 = start; int r1 = e1 * e1 + k;
        int e2 = start + 1; int r2 = e2 * e2 + k;
        int e3 = start + 2; int r3 = e3 * e3 + k;
        int e4 = start + 3; answer = e4 * e4 + k;
        expr = '$e1 → $r1\n$e2 → $r2\n$e3 → $r3\n$e4 → ?';
        explanation = 'Pattern rule: x → x² $sign.\nFor $e4: ($e4)² $sign = ${e4 * e4} $sign = $answer.';
        break;

      case 1:
        // Concept 2: Consecutive Product: x -> x * (x + 1)
        int start2 = _random.nextInt(5) + 2;
        int p1 = start2; int pr1 = p1 * (p1 + 1);
        int p2 = start2 + 1; int pr2 = p2 * (p2 + 1);
        int p3 = start2 + 2; int pr3 = p3 * (p3 + 1);
        int p4 = start2 + 3; answer = p4 * (p4 + 1);
        expr = '$p1 → $pr1\n$p2 → $pr2\n$p3 → $pr3\n$p4 → ?';
        explanation = 'Pattern rule: x → x × (x + 1).\nFor $p4: $p4 × ${p4 + 1} = $answer.';
        break;

      case 2:
        // Concept 3: Multiplier + Constant: (a * x) + c
        final multipliers = [2, 3, 4, 5];
        int a = multipliers[_random.nextInt(multipliers.length)];
        int c = _random.nextInt(4) + 1;
        int start3 = _random.nextInt(4) + 2;
        int m1 = start3; int mr1 = a * m1 + c;
        int m2 = start3 + 1; int mr2 = a * m2 + c;
        int m3 = start3 + 2; int mr3 = a * m3 + c;
        int m4 = start3 + 3; answer = a * m4 + c;
        expr = '$m1 → $mr1\n$m2 → $mr2\n$m3 → $mr3\n$m4 → ?';
        explanation = 'Pattern rule: ($a × x) + $c.\nFor $m4: ($a × $m4) + $c = ${a * m4} + $c = $answer.';
        break;

      case 3:
        // Concept 4: Cube Pattern: x -> x³ ± k
        final cubeOffsets = [0, 1, -1];
        int ck = cubeOffsets[_random.nextInt(cubeOffsets.length)];
        int cstart = 2;
        int c1 = cstart; int cr1 = (c1 * c1 * c1) + ck;
        int c2 = cstart + 1; int cr2 = (c2 * c2 * c2) + ck;
        int c3 = cstart + 2; int cr3 = (c3 * c3 * c3) + ck;
        int c4 = cstart + 3; answer = (c4 * c4 * c4) + ck;
        String cSign = ck == 0 ? '' : (ck > 0 ? ' + $ck' : ' - ${ck.abs()}');
        expr = '$c1 → $cr1\n$c2 → $cr2\n$c3 → $cr3\n$c4 → ?';
        explanation = 'Pattern rule: x → x³$cSign.\nFor $c4: ($c4)³$cSign = ${c4 * c4 * c4}$cSign = $answer.';
        break;

      case 4:
        // Concept 5: Two-Input Custom Operator a ⊕ b = (a × b) + (a + b)
        int opA = _random.nextInt(3) + 2;
        int opB = opA + 1;
        int o1 = (opA * opB) + (opA + opB);
        int a2 = opA + 1; int b2 = opB + 1;
        int o2 = (a2 * b2) + (a2 + b2);
        int a3 = a2 + 1; int b3 = b2 + 1;
        int o3 = (a3 * b3) + (a3 + b3);
        int a4 = a3 + 1; int b4 = b3 + 1;
        answer = (a4 * b4) + (a4 + b4);
        expr = '$opA ⊕ $opB = $o1\n$a2 ⊕ $b2 = $o2\n$a3 ⊕ $b3 = $o3\n$a4 ⊕ $b4 = ?';
        explanation = 'Operator logic: a ⊕ b = (a × b) + (a + b).\nFor $a4 ⊕ $b4: ($a4 × $b4) + ($a4 + $b4) = ${a4 * b4} + ${a4 + b4} = $answer.';
        break;

      case 5:
        // Concept 6: Digit Multiplication x -> d1 × d2
        final digitPairs = [
          [23, 6, '2 × 3'],
          [34, 12, '3 × 4'],
          [45, 20, '4 × 5'],
          [56, 30, '5 × 6'],
          [67, 42, '6 × 7'],
          [78, 56, '7 × 8'],
        ];
        int dOffset = _random.nextInt(3);
        var dp1 = digitPairs[dOffset];
        var dp2 = digitPairs[dOffset + 1];
        var dp3 = digitPairs[dOffset + 2];
        var dp4 = digitPairs[dOffset + 3];
        answer = dp4[1] as int;
        expr = '${dp1[0]} → ${dp1[1]}\n${dp2[0]} → ${dp2[1]}\n${dp3[0]} → ${dp3[1]}\n${dp4[0]} → ?';
        explanation = 'Rule: Multiply the two digits together.\nFor ${dp4[0]}: ${dp4[2]} = ${dp4[1]}.';
        break;

      case 6:
        // Concept 7: Progressive Multipliers: ×2, ×3, ×4, ×5
        int pBase = _random.nextInt(3) + 2;
        int ps1 = pBase;
        int ps2 = ps1 * 2;
        int ps3 = ps2 * 3;
        int ps4 = ps3 * 4;
        answer = ps4 * 5;
        expr = '$ps1 → $ps2 (×2)\n$ps2 → $ps3 (×3)\n$ps3 → $ps4 (×4)\n$ps4 → ?';
        explanation = 'Multiply by ascending integers (×2, ×3, ×4, ×5).\nNext step: $ps4 × 5 = $answer.';
        break;

      default:
        // Concept 8: Pair Sum of Squares: [a, b] -> a² + b²
        int pairStart = _random.nextInt(3) + 1;
        int sa1 = pairStart; int sb1 = pairStart + 1; int sr1 = sa1 * sa1 + sb1 * sb1;
        int sa2 = pairStart + 1; int sb2 = pairStart + 2; int sr2 = sa2 * sa2 + sb2 * sb2;
        int sa3 = pairStart + 2; int sb3 = pairStart + 3; int sr3 = sa3 * sa3 + sb3 * sb3;
        int sa4 = pairStart + 3; int sb4 = pairStart + 4; answer = sa4 * sa4 + sb4 * sb4;
        expr = '[$sa1, $sb1] → $sr1\n[$sa2, $sb2] → $sr2\n[$sa3, $sb3] → $sr3\n[$sa4, $sb4] → ?';
        explanation = 'Rule: Sum of squares of the pair: a² + b².\nFor [$sa4, $sb4]: ($sa4)² + ($sb4)² = ${sa4 * sa4} + ${sb4 * sb4} = $answer.';
        break;
    }

    return GeneratedQuestion(
      id: id,
      category: 'Number Puzzles',
      questionType: 'puzzle',
      displayExpression: expr,
      correctAnswer: answer.toString(),
      answerOptions: _generateDistractors(answer),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // Helper for generating 4 unique multiple-choice distractors
  static List<String> _generateDistractors(int correctAnswer, {int count = 4}) {
    Set<int> options = {correctAnswer};
    final deltas = [1, -1, 2, -2, 5, -5, 10, -10, 3, -3, 4, -4, 7, -7];
    deltas.shuffle(_random);

    for (int d in deltas) {
      if (options.length >= count) break;
      int candidate = correctAnswer + d;
      if (candidate != correctAnswer && candidate >= 0) {
        options.add(candidate);
      }
    }

    int offset = 11;
    while (options.length < count) {
      options.add(correctAnswer + offset);
      offset += 3;
    }

    List<String> list = options.map((e) => e.toString()).toList();
    list.shuffle(_random);
    return list;
  }
}
