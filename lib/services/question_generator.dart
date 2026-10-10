import 'dart:math';
import '../../data/models.dart';

class QuestionGenerator {
  static final Random _random = Random();

  static List<GeneratedQuestion> generateQuestions(PracticeConfiguration config) {
    List<GeneratedQuestion> questions = [];
    for (int i = 0; i < config.questionCount; i++) {
      questions.add(_generateSingleQuestion(config, 'q_${DateTime.now().millisecondsSinceEpoch}_$i'));
    }
    return questions;
  }

  static GeneratedQuestion _generateSingleQuestion(PracticeConfiguration config, String id) {
    String category = config.category;
    if (category == 'Mixed Practice' || category == 'Custom Practice') {
      final pool = [
        'Basic Arithmetic',
        'Random Calculations',
        'BODMAS Challenge',
        'Number Series',
        'Inequalities',
        'Mental Calculation',
        'Missing Number',
        'Number Puzzles',
      ];
      category = pool[_random.nextInt(pool.length)];
    }

    switch (category) {
      case 'Basic Arithmetic':
        return _generateArithmetic(id, config.difficulty);
      case 'Random Calculations':
        return _generateRandomCalculations(id, config.difficulty);
      case 'BODMAS Challenge':
        return _generateBodmas(id, config.difficulty);
      case 'Number Series':
        return _generateNumberSeries(id, config.difficulty);
      case 'Inequalities':
        return _generateInequality(id, config.difficulty);
      case 'Mental Calculation':
        return _generateMentalCalculation(id, config.difficulty);
      case 'Missing Number':
        return _generateMissingNumber(id, config.difficulty);
      case 'Number Puzzles':
        return _generateNumberPuzzle(id, config.difficulty);
      default:
        return _generateArithmetic(id, config.difficulty);
    }
  }

  // 1. Basic Arithmetic
  static GeneratedQuestion _generateArithmetic(String id, String difficulty) {
    final ops = ['+', '-', '×', '÷'];
    final op = ops[_random.nextInt(ops.length)];
    int maxVal = difficulty == 'Hard' ? 99 : (difficulty == 'Medium' ? 50 : 25);
    int minVal = difficulty == 'Hard' ? 15 : (difficulty == 'Medium' ? 10 : 2);

    int a = minVal + _random.nextInt(maxVal - minVal + 1);
    int b = minVal + _random.nextInt(maxVal - minVal + 1);
    int answer;
    String expr;
    String explanation;

    if (op == '+') {
      answer = a + b;
      expr = '$a + $b = ?';
      explanation = 'Mental shortcut: Break into tens and units: ($a) + ($b) = ${((a ~/ 10) + (b ~/ 10)) * 10} + ${(a % 10) + (b % 10)} = $answer.';
    } else if (op == '-') {
      if (a < b) {
        int temp = a; a = b; b = temp;
      }
      answer = a - b;
      expr = '$a - $b = ?';
      explanation = 'Subtract in chunks: $a - ${(b ~/ 10) * 10} = ${a - ((b ~/ 10) * 10)}, then subtract ${b % 10} = $answer.';
    } else if (op == '×') {
      int mulA = difficulty == 'Hard' ? (_random.nextInt(15) + 6) : (_random.nextInt(10) + 3);
      int mulB = difficulty == 'Hard' ? (_random.nextInt(12) + 4) : (_random.nextInt(9) + 2);
      answer = mulA * mulB;
      expr = '$mulA × $mulB = ?';
      explanation = 'Multiplication: $mulA × $mulB = $answer. You can decompose: $mulA × ${mulB ~/ 2} × 2.';
    } else {
      int divisor = _random.nextInt(10) + 2;
      int quotient = _random.nextInt(12) + 2;
      int dividend = divisor * quotient;
      answer = quotient;
      expr = '$dividend ÷ $divisor = ?';
      explanation = 'Division is inverse multiplication: $divisor × ? = $dividend. Since $divisor × $quotient = $dividend, the answer is $quotient.';
    }

    return GeneratedQuestion(
      id: id,
      category: 'Basic Arithmetic',
      questionType: 'arithmetic',
      displayExpression: expr,
      correctAnswer: answer.toString(),
      answerOptions: _generateDistractors(answer),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // 2. Random Calculations (e.g. percentages, squares, mixed operations)
  static GeneratedQuestion _generateRandomCalculations(String id, String difficulty) {
    int mode = _random.nextInt(3);
    if (mode == 0) {
      // Square calculation
      int n = difficulty == 'Hard' ? (_random.nextInt(20) + 15) : (_random.nextInt(15) + 5);
      int answer = n * n;
      String expr = '$n² = ?';
      String explanation = 'Square of $n: $n × $n = $answer. Mental tip: ${(n - 1)} × ${(n + 1)} + 1 = ${(n - 1) * (n + 1)} + 1 = $answer.';
      return GeneratedQuestion(
        id: id,
        category: 'Random Calculations',
        questionType: 'square',
        displayExpression: expr,
        correctAnswer: answer.toString(),
        answerOptions: _generateDistractors(answer),
        difficulty: difficulty,
        explanation: explanation,
      );
    } else if (mode == 1) {
      // Percentage calculation (e.g. 20% of 150)
      final percents = [10, 20, 25, 50, 75];
      int pct = percents[_random.nextInt(percents.length)];
      int base = (_random.nextInt(10) + 2) * 20; // 40, 60, 80...
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
      // 3-operand rapid calculation: a + b - c
      int a = _random.nextInt(30) + 10;
      int b = _random.nextInt(30) + 10;
      int c = _random.nextInt(20) + 5;
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

  // 3. BODMAS Challenge
  static GeneratedQuestion _generateBodmas(String id, String difficulty) {
    int type = _random.nextInt(3);
    String expr;
    int answer;
    String explanation;

    if (type == 0) {
      // (a + b) × c
      int a = _random.nextInt(10) + 2;
      int b = _random.nextInt(10) + 2;
      int c = _random.nextInt(6) + 2;
      answer = (a + b) * c;
      expr = '($a + $b) × $c = ?';
      explanation = 'BODMAS rule: Solve brackets first ($a + $b = ${a + b}), then multiply by $c: ${a + b} × $c = $answer.';
    } else if (type == 1) {
      // a + b × c
      int a = _random.nextInt(20) + 5;
      int b = _random.nextInt(8) + 2;
      int c = _random.nextInt(8) + 2;
      answer = a + (b * c);
      expr = '$a + $b × $c = ?';
      explanation = 'BODMAS rule: Multiplication comes before addition! $b × $c = ${b * c}. Then $a + ${b * c} = $answer.';
    } else {
      // a × b - c ÷ d (with clean division)
      int d = _random.nextInt(5) + 2;
      int divResult = _random.nextInt(6) + 2;
      int c = d * divResult;
      int a = _random.nextInt(8) + 2;
      int b = _random.nextInt(6) + 2;
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

  // 4. Number Series
  static GeneratedQuestion _generateNumberSeries(String id, String difficulty) {
    int type = _random.nextInt(3);
    List<int> seq = [];
    int nextVal;
    String explanation;

    if (type == 0) {
      // Arithmetic progression (+d)
      int start = _random.nextInt(20) + 3;
      int d = _random.nextInt(7) + 2;
      seq = [start, start + d, start + 2 * d, start + 3 * d];
      nextVal = start + 4 * d;
      explanation = 'Pattern: Arithmetic progression with common difference +$d. Next number is ${seq.last} + $d = $nextVal.';
    } else if (type == 1) {
      // Geometric progression (×2 or ×3)
      int start = _random.nextInt(4) + 2;
      int ratio = 2;
      seq = [start, start * 2, start * 4, start * 8];
      nextVal = start * 16;
      explanation = 'Pattern: Each term is multiplied by $ratio. Next number is ${seq.last} × $ratio = $nextVal.';
    } else {
      // Difference increases by 1, 2, 3...
      int start = _random.nextInt(10) + 1;
      int step = 2;
      seq.add(start);
      for (int i = 0; i < 3; i++) {
        seq.add(seq.last + step);
        step += 2;
      }
      nextVal = seq.last + step;
      explanation = 'Pattern: The difference between consecutive numbers increases by 2. Next term is ${seq.last} + $step = $nextVal.';
    }

    return GeneratedQuestion(
      id: id,
      category: 'Number Series',
      questionType: 'series',
      displayExpression: '${seq.join(", ")}, ?',
      correctAnswer: nextVal.toString(),
      answerOptions: _generateDistractors(nextVal),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // 5. Inequalities
  static GeneratedQuestion _generateInequality(String id, String difficulty) {
    int a1 = _random.nextInt(20) + 5;
    int a2 = _random.nextInt(10) + 2;
    int left = a1 + a2;

    int b1 = _random.nextInt(20) + 5;
    int b2 = _random.nextInt(10) + 2;
    int right = b1 + b2;

    String answer;
    if (left > right) {
      answer = '>';
    } else if (left < right) {
      answer = '<';
    } else {
      answer = '=';
    }

    String expr = '($a1 + $a2) [ ? ] ($b1 + $b2)';
    String explanation = 'Left side = $a1 + $a2 = $left. Right side = $b1 + $b2 = $right. Since $left $answer $right, the correct symbol is $answer.';

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

  // 6. Mental Calculation (Sequential operations)
  static GeneratedQuestion _generateMentalCalculation(String id, String difficulty) {
    int stepCount = difficulty == 'Hard' ? 5 : (difficulty == 'Medium' ? 4 : 3);
    int current = _random.nextInt(25) + 15;
    List<String> steps = [current.toString()];
    List<String> stepExplanations = ['Start with $current'];

    for (int i = 1; i < stepCount; i++) {
      bool isAdd = _random.nextBool();
      int val = _random.nextInt(15) + 3;
      if (isAdd) {
        current += val;
        steps.add('+ $val');
        stepExplanations.add('Add $val -> $current');
      } else {
        if (current - val < 5) {
          current += val;
          steps.add('+ $val');
          stepExplanations.add('Add $val -> $current');
        } else {
          current -= val;
          steps.add('- $val');
          stepExplanations.add('Subtract $val -> $current');
        }
      }
    }

    int answer = current;
    String expr = steps.join(' ');
    String explanation = 'Sequential steps:\n${stepExplanations.join("\n")} -> Final result = $answer.';

    return GeneratedQuestion(
      id: id,
      category: 'Mental Calculation',
      questionType: 'mental',
      displayExpression: expr,
      correctAnswer: answer.toString(),
      answerOptions: _generateDistractors(answer),
      difficulty: difficulty,
      explanation: explanation,
      mentalSteps: steps,
    );
  }

  // 7. Missing Number
  static GeneratedQuestion _generateMissingNumber(String id, String difficulty) {
    int type = _random.nextInt(2);
    String expr;
    int answer;
    String explanation;

    if (type == 0) {
      int known = _random.nextInt(40) + 10;
      answer = _random.nextInt(30) + 5;
      int total = known + answer;
      expr = '$known + ? = $total';
      explanation = 'Solve for ?: ? = $total - $known = $answer.';
    } else {
      int factor = _random.nextInt(9) + 3;
      answer = _random.nextInt(10) + 2;
      int product = factor * answer;
      expr = '? × $factor = $product';
      explanation = 'Solve for ?: ? = $product ÷ $factor = $answer.';
    }

    return GeneratedQuestion(
      id: id,
      category: 'Missing Number',
      questionType: 'missing',
      displayExpression: expr,
      correctAnswer: answer.toString(),
      answerOptions: _generateDistractors(answer),
      difficulty: difficulty,
      explanation: explanation,
    );
  }

  // 8. Number Puzzles
  static GeneratedQuestion _generateNumberPuzzle(String id, String difficulty) {
    int base = _random.nextInt(6) + 3;
    int answer = (base + 3) * (base + 3);
    String expr = '$base -> ${base * base}\n${base + 1} -> ${(base + 1) * (base + 1)}\n${base + 3} -> ?';
    String explanation = 'Notice pattern: n -> n². For ${base + 3}, the answer is (${base + 3})² = $answer.';

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
