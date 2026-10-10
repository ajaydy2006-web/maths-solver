// CALCUP Mobile Application Core Engine

// --- 1. AUDIO & HAPTICS ENGINE (Web Audio API) ---
class SoundManager {
  constructor() {
    this.ctx = null;
    this.enabled = true;
    this.hapticsEnabled = true;
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      if (AudioCtx) this.ctx = new AudioCtx();
    }
  }

  playCorrect() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const now = this.ctx.currentTime;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(523.25, now); // C5
      osc.frequency.exponentialRampToValueAtTime(659.25, now + 0.12); // E5
      gain.gain.setValueAtTime(0.2, now);
      gain.gain.exponentialRampToValueAtTime(0.01, now + 0.25);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now);
      osc.stop(now + 0.25);
    } catch (e) {}

    if (this.hapticsEnabled && navigator.vibrate) {
      navigator.vibrate(30);
    }
  }

  playWrong() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const now = this.ctx.currentTime;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(220, now);
      osc.frequency.exponentialRampToValueAtTime(140, now + 0.2);
      gain.gain.setValueAtTime(0.3, now);
      gain.gain.exponentialRampToValueAtTime(0.01, now + 0.25);
      osc.connect(gain);
      gain.connect(this.ctx.destination);
      osc.start(now);
      osc.stop(now + 0.25);
    } catch (e) {}

    if (this.hapticsEnabled && navigator.vibrate) {
      navigator.vibrate([60, 40, 60]);
    }
  }

  playFanfare() {
    if (!this.enabled) return;
    this.init();
    if (!this.ctx) return;
    try {
      const notes = [440, 554, 659, 880];
      notes.forEach((freq, idx) => {
        const now = this.ctx.currentTime + (idx * 0.1);
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.frequency.setValueAtTime(freq, now);
        gain.gain.setValueAtTime(0.2, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.35);
        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start(now);
        osc.stop(now + 0.35);
      });
    } catch (e) {}
  }
}

const sounds = new SoundManager();

// --- 2. CATEGORIES & ICONS ---
const CATEGORIES = [
  { name: 'Basic Arithmetic', icon: '➕', color: '#A7BFFF' },
  { name: 'Random Calculations', icon: '🔀', color: '#BCE8A3' },
  { name: 'BODMAS Challenge', icon: '📐', color: '#FFB7B0' },
  { name: 'Number Series', icon: '🔢', color: '#D6B8FF' },
  { name: 'Inequalities', icon: '⚖️', color: '#FFC928' },
  { name: 'Mental Calculation', icon: '🧠', color: '#A7BFFF' },
  { name: 'Missing Number', icon: '❓', color: '#BCE8A3' },
  { name: 'Number Puzzles', icon: '🧩', color: '#FFB7B0' },
  { name: 'Mixed Practice', icon: '⚡', color: '#D6B8FF' },
  { name: 'Custom Practice', icon: '⚙️', color: '#FFC928' }
];

// --- 3. QUESTION GENERATOR (ALGORITHMIC) ---
class QuestionGenerator {
  static recentSignatures = new Set();

  static generate(category, difficulty, count = 10) {
    const list = [];
    for (let i = 0; i < count; i++) {
      list.push(this.generateSingle(category, difficulty, i));
    }
    return list;
  }

  static generateSingle(cat, diff, idx) {
    let q;
    let attempts = 0;
    do {
      q = this._generateSingleRaw(cat, diff, idx);
      attempts++;
    } while (this.recentSignatures.has(q.expr) && attempts < 15);

    this.recentSignatures.add(q.expr);
    if (this.recentSignatures.size > 80) {
      const first = this.recentSignatures.values().next().value;
      this.recentSignatures.delete(first);
    }
    return q;
  }

  static _generateSingleRaw(cat, diff, idx) {
    let activeCat = cat;
    if (cat === 'Mixed Practice' || cat === 'Custom Practice') {
      const pool = [
        'Basic Arithmetic',
        'Random Calculations',
        'BODMAS Challenge',
        'Number Series',
        'Inequalities',
        'Missing Number',
        'Mental Calculation',
        'Number Puzzles'
      ];
      activeCat = pool[Math.floor(Math.random() * pool.length)];
    }

    switch (activeCat) {
      case 'Basic Arithmetic': return this.genArithmetic(diff, idx);
      case 'Random Calculations': return this.genRandomCalc(diff, idx);
      case 'BODMAS Challenge': return this.genBodmas(diff, idx);
      case 'Number Series': return this.genSeries(diff, idx);
      case 'Inequalities': return this.genInequality(diff, idx);
      case 'Mental Calculation': return this.genMental(diff, idx);
      case 'Missing Number': return this.genMissing(diff, idx);
      case 'Number Puzzles': return this.genPuzzle(diff, idx);
      default: return this.genArithmetic(diff, idx);
    }
  }

  static genArithmetic(diff, id) {
    const ops = ['+', '-', '×', '÷'];
    const op = ops[Math.floor(Math.random() * ops.length)];
    const maxVal = diff === 'Hard' ? 95 : (diff === 'Medium' ? 50 : 25);
    const minVal = diff === 'Hard' ? 16 : (diff === 'Medium' ? 8 : 3);
    let a = Math.floor(Math.random() * (maxVal - minVal + 1)) + minVal;
    let b = Math.floor(Math.random() * (maxVal - minVal + 1)) + minVal;
    while (a === b) {
      b = Math.floor(Math.random() * (maxVal - minVal + 1)) + minVal;
    }

    let ans, expr, exp;

    if (op === '+') {
      ans = a + b;
      expr = `${a} + ${b} = ?`;
      exp = `Add tens then units: (${Math.floor(a/10)*10} + ${Math.floor(b/10)*10}) + (${a%10} + ${b%10}) = ${ans}.`;
    } else if (op === '-') {
      if (a < b) { const t = a; a = b; b = t; }
      ans = a - b;
      expr = `${a} - ${b} = ?`;
      exp = `Subtract in parts: ${a} - ${Math.floor(b/10)*10} = ${a - Math.floor(b/10)*10}, then minus ${b%10} = ${ans}.`;
    } else if (op === '×') {
      a = diff === 'Hard' ? Math.floor(Math.random() * 12) + 6 : Math.floor(Math.random() * 8) + 3;
      b = diff === 'Hard' ? Math.floor(Math.random() * 10) + 4 : Math.floor(Math.random() * 7) + 2;
      while (a === b) {
        b = diff === 'Hard' ? Math.floor(Math.random() * 10) + 4 : Math.floor(Math.random() * 7) + 2;
      }
      ans = a * b;
      expr = `${a} × ${b} = ?`;
      exp = `Multiplication: ${a} × ${b} = ${ans}.`;
    } else {
      b = Math.floor(Math.random() * 8) + 2;
      let quot = Math.floor(Math.random() * 10) + 2;
      while (b === quot) {
        quot = Math.floor(Math.random() * 10) + 2;
      }
      a = b * quot;
      ans = quot;
      expr = `${a} ÷ ${b} = ?`;
      exp = `Division is reverse multiplication: ${b} × ${quot} = ${a}, so answer is ${quot}.`;
    }

    return {
      id, category: 'Basic Arithmetic', expr, ans: ans.toString(),
      options: this.genDistractors(ans), explanation: exp, diff
    };
  }

  static genRandomCalc(diff, id) {
    const mode = Math.floor(Math.random() * 3);
    if (mode === 0) {
      const n = Math.floor(Math.random() * 14) + 6;
      const ans = n * n;
      return {
        id, category: 'Random Calculations', expr: `${n}² = ?`, ans: ans.toString(),
        options: this.genDistractors(ans), explanation: `Square of ${n}: ${n} × ${n} = ${ans}.`, diff
      };
    } else if (mode === 1) {
      const pcts = [10, 20, 25, 50, 75];
      const p = pcts[Math.floor(Math.random() * pcts.length)];
      const base = (Math.floor(Math.random() * 9) + 2) * 20;
      const ans = Math.round((p * base) / 100);
      return {
        id, category: 'Random Calculations', expr: `${p}% of ${base} = ?`, ans: ans.toString(),
        options: this.genDistractors(ans), explanation: `10% of ${base} is ${base/10}. Multiplying gives ${p}% = ${ans}.`, diff
      };
    } else {
      const a = Math.floor(Math.random() * 30) + 12;
      let b = Math.floor(Math.random() * 30) + 12;
      while (b === a) { b = Math.floor(Math.random() * 30) + 12; }
      let c = Math.floor(Math.random() * 18) + 5;
      while (c === a || c === b) { c = Math.floor(Math.random() * 18) + 5; }
      const ans = a + b - c;
      return {
        id, category: 'Random Calculations', expr: `${a} + ${b} - ${c} = ?`, ans: ans.toString(),
        options: this.genDistractors(ans), explanation: `First: ${a} + ${b} = ${a+b}. Then: ${a+b} - ${c} = ${ans}.`, diff
      };
    }
  }

  static genBodmas(diff, id) {
    const a = Math.floor(Math.random() * 9) + 2;
    let b = Math.floor(Math.random() * 9) + 2;
    while (b === a) { b = Math.floor(Math.random() * 9) + 2; }
    let c = Math.floor(Math.random() * 7) + 2;
    while (c === a || c === b) { c = Math.floor(Math.random() * 7) + 2; }

    const isBracket = Math.random() > 0.5;
    let ans, expr, exp;

    if (isBracket) {
      ans = (a + b) * c;
      expr = `(${a} + ${b}) × ${c} = ?`;
      exp = `BODMAS: Brackets first (${a} + ${b} = ${a+b}), then multiply by ${c} = ${ans}.`;
    } else {
      ans = a + (b * c);
      expr = `${a} + ${b} × ${c} = ?`;
      exp = `BODMAS: Multiply first (${b} × ${c} = ${b*c}), then add ${a} = ${ans}.`;
    }
    return {
      id, category: 'BODMAS Challenge', expr, ans: ans.toString(),
      options: this.genDistractors(ans), explanation: exp, diff
    };
  }

  static genSeries(diff, id) {
    const types = [
      // Arithmetic
      () => {
        const start = Math.floor(Math.random() * 15) + 3;
        const step = Math.floor(Math.random() * 7) + 3;
        const seq = [start, start + step, start + 2 * step, start + 3 * step];
        const ans = start + 4 * step;
        return {
          expr: `${seq.join(', ')}, ?`,
          ans: ans.toString(),
          exp: `Arithmetic sequence adding +${step} each step: ${seq[3]} + ${step} = ${ans}.`
        };
      },
      // Increasing difference (+2, +4, +6, +8...)
      () => {
        const start = Math.floor(Math.random() * 10) + 2;
        const diffStart = Math.floor(Math.random() * 3) + 2;
        const s0 = start;
        const s1 = s0 + diffStart;
        const s2 = s1 + (diffStart + 2);
        const s3 = s2 + (diffStart + 4);
        const ans = s3 + (diffStart + 6);
        return {
          expr: `${s0}, ${s1}, ${s2}, ${s3}, ?`,
          ans: ans.toString(),
          exp: `Differences increase by +2 each step (+${diffStart}, +${diffStart+2}, +${diffStart+4}, +${diffStart+6}): ${s3} + ${diffStart+6} = ${ans}.`
        };
      },
      // Doubling difference (+3, +6, +12, +24...)
      () => {
        const start = Math.floor(Math.random() * 8) + 2;
        const step = Math.floor(Math.random() * 3) + 2;
        const s0 = start;
        const s1 = s0 + step;
        const s2 = s1 + step * 2;
        const s3 = s2 + step * 4;
        const ans = s3 + step * 8;
        return {
          expr: `${s0}, ${s1}, ${s2}, ${s3}, ?`,
          ans: ans.toString(),
          exp: `Differences double each step (+${step}, +${step*2}, +${step*4}, +${step*8}): ${s3} + ${step*8} = ${ans}.`
        };
      },
      // Squares sequence
      () => {
        const start = Math.floor(Math.random() * 4) + 2;
        const seq = [start*start, (start+1)*(start+1), (start+2)*(start+2), (start+3)*(start+3)];
        const ans = (start+4)*(start+4);
        return {
          expr: `${seq.join(', ')}, ?`,
          ans: ans.toString(),
          exp: `Perfect squares sequence: ${start}², ${start+1}², ${start+2}², ${start+3}², ${start+4}² = ${ans}.`
        };
      }
    ];

    const pick = types[Math.floor(Math.random() * types.length)]();
    return {
      id, category: 'Number Series', expr: pick.expr, ans: pick.ans,
      options: this.genDistractors(parseInt(pick.ans)), explanation: pick.exp, diff
    };
  }

  static genInequality(diff, id) {
    const a = Math.floor(Math.random() * 22) + 5;
    let b = Math.floor(Math.random() * 14) + 2;
    while (b === a) { b = Math.floor(Math.random() * 14) + 2; }
    let c = Math.floor(Math.random() * 22) + 5;
    while (c === a || c === b) { c = Math.floor(Math.random() * 22) + 5; }
    let d = Math.floor(Math.random() * 14) + 2;
    while (d === a || d === b || d === c) { d = Math.floor(Math.random() * 14) + 2; }

    const left = a + b;
    const right = c + d;
    let ans = '=';
    if (left > right) ans = '>';
    if (left < right) ans = '<';

    const options = ['>', '<', '=', '≠'].sort(() => Math.random() - 0.5);
    return {
      id, category: 'Inequalities', expr: `(${a}+${b}) [?] (${c}+${d})`, ans,
      options, explanation: `Left = ${left}, Right = ${right}. Since ${left} ${ans} ${right}, symbol is ${ans}.`, diff
    };
  }

  static genMental(diff, id) {
    const count = diff === 'Hard' ? 5 : (diff === 'Medium' ? 4 : 3);
    let cur = Math.floor(Math.random() * 20) + 15;
    const steps = [cur.toString()];
    const expSteps = [`Start with ${cur}`];

    let lastV = -1;
    for (let i = 1; i < count; i++) {
      const isAdd = Math.random() > 0.5;
      let v = Math.floor(Math.random() * 12) + 3;
      while (v === lastV) {
        v = Math.floor(Math.random() * 12) + 3;
      }
      lastV = v;

      if (isAdd || cur - v < 5) {
        cur += v;
        steps.push(`+ ${v}`);
        expSteps.push(`Add ${v} -> ${cur}`);
      } else {
        cur -= v;
        steps.push(`- ${v}`);
        expSteps.push(`Subtract ${v} -> ${cur}`);
      }
    }
    return {
      id, category: 'Mental Calculation', expr: steps.join(' '), ans: cur.toString(),
      options: this.genDistractors(cur),
      explanation: `Step-by-step:\n${expSteps.join('\n')} => Answer is ${cur}.`,
      mentalSteps: steps, diff
    };
  }

  static genMissing(diff, id) {
    const a = Math.floor(Math.random() * 32) + 10;
    let b = Math.floor(Math.random() * 24) + 5;
    while (a === b) {
      b = Math.floor(Math.random() * 24) + 5;
    }
    const sum = a + b;
    return {
      id, category: 'Missing Number', expr: `${a} + ? = ${sum}`, ans: b.toString(),
      options: this.genDistractors(b), explanation: `? = ${sum} - ${a} = ${b}.`, diff
    };
  }

  static genPuzzle(diff, id) {
    const concepts = [
      // Concept 1: x -> x² + k or x² - k
      () => {
        const k = [1, 2, 3, -1, -2][Math.floor(Math.random() * 5)];
        const sign = k >= 0 ? `+ ${k}` : `- ${Math.abs(k)}`;
        const start = Math.floor(Math.random() * 4) + 2;
        const e1 = start; const r1 = e1 * e1 + k;
        const e2 = start + 1; const r2 = e2 * e2 + k;
        const e3 = start + 2; const r3 = e3 * e3 + k;
        const e4 = start + 3; const ans = e4 * e4 + k;
        return {
          expr: `${e1} → ${r1}\n${e2} → ${r2}\n${e3} → ${r3}\n${e4} → ?`,
          ans: ans.toString(),
          explanation: `Pattern rule is: x → x² ${sign}.\nFor ${e4}: (${e4})² ${sign} = ${e4 * e4} ${sign} = ${ans}.`
        };
      },
      // Concept 2: Consecutive Product: x -> x * (x + 1)
      () => {
        const start = Math.floor(Math.random() * 5) + 2;
        const e1 = start; const r1 = e1 * (e1 + 1);
        const e2 = start + 1; const r2 = e2 * (e2 + 1);
        const e3 = start + 2; const r3 = e3 * (e3 + 1);
        const e4 = start + 3; const ans = e4 * (e4 + 1);
        return {
          expr: `${e1} → ${r1}\n${e2} → ${r2}\n${e3} → ${r3}\n${e4} → ?`,
          ans: ans.toString(),
          explanation: `Pattern rule is: x → x × (x + 1).\nFor ${e4}: ${e4} × ${e4 + 1} = ${ans}.`
        };
      },
      // Concept 3: Multiplier + Offset: a * x + c
      () => {
        const a = [2, 3, 4, 5][Math.floor(Math.random() * 4)];
        const c = Math.floor(Math.random() * 4) + 1;
        const start = Math.floor(Math.random() * 4) + 2;
        const e1 = start; const r1 = a * e1 + c;
        const e2 = start + 1; const r2 = a * e2 + c;
        const e3 = start + 2; const r3 = a * e3 + c;
        const e4 = start + 3; const ans = a * e4 + c;
        return {
          expr: `${e1} → ${r1}\n${e2} → ${r2}\n${e3} → ${r3}\n${e4} → ?`,
          ans: ans.toString(),
          explanation: `Pattern rule is: (${a} × x) + ${c}.\nFor ${e4}: (${a} × ${e4}) + ${c} = ${a * e4} + ${c} = ${ans}.`
        };
      },
      // Concept 4: Cube Pattern: x -> x³ or x³ - 1
      () => {
        const k = [0, 1, -1][Math.floor(Math.random() * 3)];
        const start = 2;
        const e1 = start; const r1 = (e1 * e1 * e1) + k;
        const e2 = start + 1; const r2 = (e2 * e2 * e2) + k;
        const e3 = start + 2; const r3 = (e3 * e3 * e3) + k;
        const e4 = start + 3; const ans = (e4 * e4 * e4) + k;
        const sign = k === 0 ? '' : (k > 0 ? ` + ${k}` : ` - ${Math.abs(k)}`);
        return {
          expr: `${e1} → ${r1}\n${e2} → ${r2}\n${e3} → ${r3}\n${e4} → ?`,
          ans: ans.toString(),
          explanation: `Pattern rule is: x → x³${sign}.\nFor ${e4}: (${e4})³${sign} = ${e4 * e4 * e4}${sign} = ${ans}.`
        };
      },
      // Concept 5: Two-Input Custom Operator a ⊕ b = (a × b) + (a + b)
      () => {
        const a1 = Math.floor(Math.random() * 3) + 2;
        const b1 = a1 + 1;
        const r1 = (a1 * b1) + (a1 + b1);
        const a2 = a1 + 1; const b2 = b1 + 1;
        const r2 = (a2 * b2) + (a2 + b2);
        const a3 = a2 + 1; const b3 = b2 + 1;
        const r3 = (a3 * b3) + (a3 + b3);
        const a4 = a3 + 1; const b4 = b3 + 1;
        const ans = (a4 * b4) + (a4 + b4);
        return {
          expr: `${a1} ⊕ ${b1} = ${r1}\n${a2} ⊕ ${b2} = ${r2}\n${a3} ⊕ ${b3} = ${r3}\n${a4} ⊕ ${b4} = ?`,
          ans: ans.toString(),
          explanation: `Operator logic: a ⊕ b = (a × b) + (a + b).\nFor ${a4} ⊕ ${b4}: (${a4} × ${b4}) + (${a4} + ${b4}) = ${a4 * b4} + ${a4 + b4} = ${ans}.`
        };
      },
      // Concept 6: Digit Multiplication x -> d1 * d2
      () => {
        const pairs = [
          [23, 6, "2 × 3"],
          [34, 12, "3 × 4"],
          [45, 20, "4 × 5"],
          [56, 30, "5 × 6"],
          [67, 42, "6 × 7"],
          [78, 56, "7 × 8"]
        ];
        const offset = Math.floor(Math.random() * 3);
        const p1 = pairs[offset];
        const p2 = pairs[offset + 1];
        const p3 = pairs[offset + 2];
        const p4 = pairs[offset + 3];
        return {
          expr: `${p1[0]} → ${p1[1]}\n${p2[0]} → ${p2[1]}\n${p3[0]} → ${p3[1]}\n${p4[0]} → ?`,
          ans: p4[1].toString(),
          explanation: `Rule: Multiply the two digits together.\nFor ${p4[0]}: ${p4[2]} = ${p4[1]}.`
        };
      },
      // Concept 7: Progressive Multipliers: ×2, ×3, ×4, ×5
      () => {
        const base = Math.floor(Math.random() * 3) + 2;
        const s1 = base;
        const s2 = s1 * 2;
        const s3 = s2 * 3;
        const s4 = s3 * 4;
        const ans = s4 * 5;
        return {
          expr: `${s1} → ${s2} (×2)\n${s2} → ${s3} (×3)\n${s3} → ${s4} (×4)\n${s4} → ?`,
          ans: ans.toString(),
          explanation: `Multiply by ascending integers (×2, ×3, ×4, ×5).\nNext step: ${s4} × 5 = ${ans}.`
        };
      },
      // Concept 8: Pair Sum of Squares: [a, b] -> a² + b²
      () => {
        const start = Math.floor(Math.random() * 3) + 1;
        const a1 = start; const b1 = start + 1; const r1 = a1 * a1 + b1 * b1;
        const a2 = start + 1; const b2 = start + 2; const r2 = a2 * a2 + b2 * b2;
        const a3 = start + 2; const b3 = start + 3; const r3 = a3 * a3 + b3 * b3;
        const a4 = start + 3; const b4 = start + 4; const ans = a4 * a4 + b4 * b4;
        return {
          expr: `[${a1}, ${b1}] → ${r1}\n[${a2}, ${b2}] → ${r2}\n[${a3}, ${b3}] → ${r3}\n[${a4}, ${b4}] → ?`,
          ans: ans.toString(),
          explanation: `Rule is sum of squares: a² + b².\nFor [${a4}, ${b4}]: ${a4}² + ${b4}² = ${a4 * a4} + ${b4 * b4} = ${ans}.`
        };
      }
    ];

    const pick = concepts[Math.floor(Math.random() * concepts.length)]();
    return {
      id,
      category: 'Number Puzzles',
      expr: pick.expr,
      ans: pick.ans,
      options: this.genDistractors(parseInt(pick.ans)),
      explanation: pick.explanation,
      diff
    };
  }

  static genDistractors(correct) {
    const set = new Set([correct]);
    const deltas = [1, -1, 2, -2, 5, -5, 10, -10, 3, -3, 4, -4, 7, -7].sort(() => Math.random() - 0.5);
    for (let d of deltas) {
      if (set.size >= 4) break;
      const cand = correct + d;
      if (cand >= 0) set.add(cand);
    }
    let offset = 11;
    while (set.size < 4) {
      set.add(correct + offset);
      offset += 3;
    }
    return Array.from(set).map(x => x.toString()).sort(() => Math.random() - 0.5);
  }
}

// --- 4. STATE STORE ---
class AppStore {
  constructor() {
    this.prefs = this.loadPrefs();
    this.sessions = this.loadSessions();
  }

  loadPrefs() {
    const raw = localStorage.getItem('calcup_prefs');
    if (raw) {
      try { return JSON.parse(raw); } catch (e) {}
    }
    return {
      displayName: 'Aspirant',
      examGoals: ['SSC', 'Banking'],
      currentLevel: 'Beginner',
      dailyGoalMinutes: 10,
      hasCompletedOnboarding: false,
      wrongAnswerThreshold: 3,
      threeWrongRestartEnabled: true,
      soundEnabled: true,
      hapticsEnabled: true
    };
  }

  savePrefs() {
    localStorage.setItem('calcup_prefs', JSON.stringify(this.prefs));
    sounds.enabled = this.prefs.soundEnabled;
    sounds.hapticsEnabled = this.prefs.hapticsEnabled;
  }

  loadSessions() {
    const raw = localStorage.getItem('calcup_sessions');
    if (raw) {
      try { return JSON.parse(raw); } catch (e) {}
    }
    return [];
  }

  saveSession(record) {
    this.sessions.unshift(record);
    localStorage.setItem('calcup_sessions', JSON.stringify(this.sessions));
  }

  clearSessions() {
    this.sessions = [];
    localStorage.removeItem('calcup_sessions');
  }

  resetAll() {
    localStorage.clear();
    this.prefs = this.loadPrefs();
    this.sessions = [];
  }

  getTodayMinutes() {
    const today = new Date().toISOString().substring(0, 10);
    const todaySecs = this.sessions
      .filter(s => s.date && s.date.startsWith(today))
      .reduce((acc, cur) => acc + (cur.durationSeconds || 0), 0);
    return Math.round(todaySecs / 60);
  }

  getStats() {
    const totalSessions = this.sessions.length;
    let totalQuestions = 0;
    let totalCorrect = 0;
    let totalSeconds = 0;
    const catMap = {};

    this.sessions.forEach(s => {
      totalQuestions += s.totalQuestions || 0;
      totalCorrect += s.correctAnswers || 0;
      totalSeconds += s.durationSeconds || 0;
      if (!catMap[s.category]) catMap[s.category] = { total: 0, correct: 0 };
      catMap[s.category].total += s.totalQuestions || 0;
      catMap[s.category].correct += s.correctAnswers || 0;
    });

    const avgAccuracy = totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0;
    return {
      totalSessions,
      totalQuestions,
      totalCorrect,
      avgAccuracy: avgAccuracy.toFixed(1),
      totalMinutes: Math.round(totalSeconds / 60),
      categoryMap: catMap,
      recent: this.sessions.slice(0, 10)
    };
  }
}

const store = new AppStore();

// --- 5. APP CONTROLLER ---
class AppController {
  constructor() {
    this.currentTab = 'home';
    this.activeConfig = {
      category: 'Basic Arithmetic',
      difficulty: 'Medium',
      timerSeconds: 60,
      questionCount: 20
    };

    // Active session state
    this.sessionQuestions = [];
    this.sessionIndex = 0;
    this.sessionCorrect = 0;
    this.sessionWrong = 0;
    this.consecutiveWrong = 0;
    this.remainingSeconds = 60;
    this.sessionTimer = null;
    this.attempts = [];
    this.questionStartTime = Date.now();
    this.isSubmitting = false;

    // Mental calculation state
    this.mentalStepTimer = null;
    this.mentalStepIdx = 0;
    this.mentalSequenceDone = false;
    this.mentalSpeed = 1.4;

    this.init();
  }

  init() {
    sounds.enabled = store.prefs.soundEnabled;
    sounds.hapticsEnabled = store.prefs.hapticsEnabled;

    this.renderCategoryGrid();
    this.renderTopicDirectory();
    this.bindEvents();

    // Route on launch
    setTimeout(() => {
      if (store.prefs.hasCompletedOnboarding) {
        this.showScreen('screen-home');
        this.refreshHomeStats();
      } else {
        this.showScreen('screen-onboarding');
      }
    }, 1200);
  }

  showScreen(id) {
    document.querySelectorAll('.screen').forEach(s => s.classList.add('hidden'));
    const target = document.getElementById(id);
    if (target) target.classList.remove('hidden');

    // Show/hide bottom nav based on screen
    const mainTabs = ['screen-home', 'screen-practice-tab', 'screen-progress', 'screen-profile'];
    const nav = document.getElementById('bottom-nav');
    if (mainTabs.includes(id)) {
      nav.style.display = 'flex';
    } else {
      nav.style.display = 'none';
    }
  }

  switchTab(tab) {
    this.currentTab = tab;
    document.querySelectorAll('.nav-item').forEach(b => {
      b.classList.toggle('active', b.dataset.tab === tab);
    });

    if (tab === 'home') {
      this.refreshHomeStats();
      this.showScreen('screen-home');
    } else if (tab === 'progress') {
      this.renderProgressDashboard();
      this.showScreen('screen-progress');
    } else if (tab === 'profile') {
      this.renderProfileScreen();
      this.showScreen('screen-profile');
    }
  }

  renderCategoryGrid() {
    const grid = document.getElementById('category-grid');
    if (!grid) return;
    grid.innerHTML = CATEGORIES.map((c, i) => `
      <div class="category-card" style="background:${c.color};" data-cat="${c.name}">
        <div class="cat-icon-bubble">${c.icon}</div>
        <strong>${c.name}</strong>
      </div>
    `).join('');

    grid.querySelectorAll('.category-card').forEach(card => {
      card.addEventListener('click', () => {
        this.openConfigModal(card.dataset.cat);
      });
    });
  }

  renderTopicDirectory() {
    const list = document.getElementById('practice-topic-list');
    if (!list) return;
    list.innerHTML = CATEGORIES.map((c, i) => `
      <div class="topic-tile" data-cat="${c.name}">
        <div class="topic-tile-left">
          <span style="font-size:24px;">${c.icon}</span>
          <div>
            <strong>${c.name}</strong>
            <p class="text-sub">Speed & accuracy drills</p>
          </div>
        </div>
        <span style="font-size:18px; color:var(--text-secondary);">→</span>
      </div>
    `).join('');

    list.querySelectorAll('.topic-tile').forEach(tile => {
      tile.addEventListener('click', () => {
        this.openConfigModal(tile.dataset.cat);
      });
    });
  }

  openConfigModal(category) {
    this.activeConfig.category = category;
    document.getElementById('config-title').textContent = category;
    this.showScreen('screen-config');
  }

  refreshHomeStats() {
    document.getElementById('home-greeting').textContent = `Hey, ${store.prefs.displayName}!`;
    document.getElementById('btn-profile-avatar').textContent = (store.prefs.displayName[0] || 'A').toUpperCase();

    const todayMins = store.getTodayMinutes();
    const goalMins = store.prefs.dailyGoalMinutes;
    const pct = goalMins > 0 ? Math.min(100, Math.round((todayMins / goalMins) * 100)) : 0;

    document.getElementById('daily-goal-fill').style.width = `${pct}%`;
    document.getElementById('daily-goal-text').textContent = `${todayMins} / ${goalMins} minutes today`;
    document.getElementById('daily-goal-percent').textContent = `${pct}%`;

    const badge = document.getElementById('badge-goal-status');
    if (todayMins >= goalMins && goalMins > 0) {
      badge.classList.remove('hidden');
    } else {
      badge.classList.add('hidden');
    }
  }

  // --- PRACTICE SESSION EXECUTION ---
  startSession() {
    this.sessionQuestions = QuestionGenerator.generate(
      this.activeConfig.category,
      this.activeConfig.difficulty,
      10
    );
    this.sessionIndex = 0;
    this.sessionCorrect = 0;
    this.sessionWrong = 0;
    this.attempts = [];
    this.elapsedSeconds = 0;
    this.isSubmitting = false;

    clearInterval(this.sessionTimer);
    this.updateTimerDisplays();
    this.sessionTimer = setInterval(() => {
      this.elapsedSeconds++;
      this.updateTimerDisplays();
    }, 1000);

    if (this.activeConfig.category === 'Mental Calculation') {
      this.startMentalSession();
    } else {
      this.startStandardSession();
    }
  }

  updateTimerDisplays() {
    const mins = Math.floor(this.elapsedSeconds / 60);
    const secs = this.elapsedSeconds % 60;
    const str = `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    const std = document.getElementById('session-timer-text');
    const mtl = document.getElementById('mental-timer-text');
    if (std) std.textContent = str;
    if (mtl) mtl.textContent = str;
  }

  startStandardSession() {
    document.getElementById('session-category-label').textContent = this.activeConfig.category;
    this.showScreen('screen-session');
    this.renderCurrentStandardQuestion();
  }

  renderCurrentStandardQuestion() {
    const q = this.sessionQuestions[this.sessionIndex];
    document.getElementById('session-q-counter').textContent = `Question ${this.sessionIndex + 1}`;
    
    // Hearts
    this.renderHearts('session-hearts');

    document.getElementById('session-expression').textContent = q.expr;
    this.questionStartTime = Date.now();
    this.isSubmitting = false;

    // Options
    const grid = document.getElementById('session-options-grid');
    grid.innerHTML = q.options.map(opt => `
      <button class="btn-answer" data-val="${opt}">${opt}</button>
    `).join('');

    grid.querySelectorAll('.btn-answer').forEach(btn => {
      btn.addEventListener('click', () => {
        this.submitAnswer(btn.dataset.val, btn);
      });
    });
  }

  renderHearts(containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;
    const threshold = store.prefs.wrongAnswerThreshold || 3;
    const livesLeft = Math.max(0, threshold - this.sessionWrong);
    container.innerHTML = Array.from({ length: threshold }).map((_, i) => `
      <span class="heart ${i < livesLeft ? 'active' : ''}">❤️</span>
    `).join('');
  }

  // --- MENTAL CALCULATION SESSION ---
  startMentalSession() {
    this.showScreen('screen-mental');
    this.playMentalQuestion();
  }

  playMentalQuestion() {
    clearInterval(this.mentalStepTimer);
    this.mentalStepIdx = 0;
    this.mentalSequenceDone = false;
    this.isSubmitting = false;
    this.questionStartTime = Date.now();

    const q = this.sessionQuestions[this.sessionIndex];
    const steps = q.mentalSteps || [q.expr];

    document.getElementById('mental-q-counter').textContent = `Question ${this.sessionIndex + 1}`;
    this.renderHearts('mental-hearts');

    const badge = document.getElementById('mental-step-badge');
    const display = document.getElementById('mental-step-text');
    const prompt = document.getElementById('mental-prompt-sub');
    const optionsGrid = document.getElementById('mental-options-grid');
    const btnReplay = document.getElementById('btn-mental-replay');

    prompt.classList.add('hidden');
    optionsGrid.classList.add('dimmed');
    btnReplay.classList.add('hidden');

    badge.textContent = `Step 1 of ${steps.length}`;
    display.textContent = steps[0];

    // Options
    optionsGrid.innerHTML = q.options.map(opt => `
      <button class="btn-answer" data-val="${opt}">${opt}</button>
    `).join('');

    optionsGrid.querySelectorAll('.btn-answer').forEach(btn => {
      btn.addEventListener('click', () => {
        if (!this.mentalSequenceDone || this.isSubmitting) return;
        this.submitAnswer(btn.dataset.val, btn);
      });
    });

    // Sequence timer
    const intervalMs = Math.round(this.mentalSpeed * 1000);
    this.mentalStepTimer = setInterval(() => {
      if (this.mentalStepIdx < steps.length - 1) {
        this.mentalStepIdx++;
        badge.textContent = `Step ${this.mentalStepIdx + 1} of ${steps.length}`;
        display.textContent = steps[this.mentalStepIdx];
      } else {
        clearInterval(this.mentalStepTimer);
        this.mentalSequenceDone = true;
        display.textContent = '= ?';
        display.style.color = 'var(--primary-orange)';
        prompt.classList.remove('hidden');
        optionsGrid.classList.remove('dimmed');
        btnReplay.classList.remove('hidden');
      }
    }, intervalMs);
  }

  submitAnswer(selected, btnEl) {
    if (this.isSubmitting) return;
    this.isSubmitting = true;

    const q = this.sessionQuestions[this.sessionIndex];
    const isCorrect = selected === q.ans;
    const duration = Math.round((Date.now() - this.questionStartTime) / 1000);

    this.attempts.push({
      question: q,
      selected,
      isCorrect,
      duration
    });

    if (isCorrect) {
      this.sessionCorrect++;
      sounds.playCorrect();
      if (btnEl) btnEl.classList.add('correct-flash');
    } else {
      this.sessionWrong++;
      sounds.playWrong();
      if (btnEl) btnEl.classList.add('wrong-flash');
      // Update hearts immediately to reflect lost life without waiting
      this.renderHearts('session-hearts');
      this.renderHearts('mental-hearts');
    }

    setTimeout(() => {
      // 3-wrong answer termination rule check based on total mistakes
      const threshold = store.prefs.wrongAnswerThreshold || 3;
      if (this.sessionWrong >= threshold) {
        this.terminateMistakeSession();
        return;
      }

      // Continue asking questions endlessly until lives are lost
      this.sessionIndex++;
      if (this.sessionIndex >= this.sessionQuestions.length) {
        const moreQuestions = QuestionGenerator.generate(
          this.activeConfig.category,
          this.activeConfig.difficulty,
          10
        );
        this.sessionQuestions.push(...moreQuestions);
      }

      if (this.activeConfig.category === 'Mental Calculation') {
        this.playMentalQuestion();
      } else {
        this.renderCurrentStandardQuestion();
      }
    }, 400);
  }

  terminateMistakeSession() {
    clearInterval(this.sessionTimer);
    clearInterval(this.mentalStepTimer);
    sounds.playWrong();
    this.finalizeSession(true);
  }

  finalizeSession(terminatedDueToMistakes = false) {
    clearInterval(this.sessionTimer);
    clearInterval(this.mentalStepTimer);

    const total = this.attempts.length;
    const duration = Math.max(1, this.elapsedSeconds);
    const score = this.sessionCorrect * 10;

    const sessionRecord = {
      category: this.activeConfig.category,
      date: new Date().toISOString(),
      score,
      correctAnswers: this.sessionCorrect,
      incorrectAnswers: this.sessionWrong,
      totalQuestions: total,
      durationSeconds: duration,
      attempts: this.attempts,
      terminated: terminatedDueToMistakes
    };

    store.saveSession(sessionRecord);
    if (!terminatedDueToMistakes) {
      sounds.playFanfare();
    }

    // Populate Results
    const badgeEl = document.getElementById('res-badge');
    const titleEl = document.getElementById('res-title');
    const catSubEl = document.getElementById('result-category-sub');

    if (terminatedDueToMistakes) {
      if (badgeEl) badgeEl.textContent = '🛑';
      if (titleEl) titleEl.textContent = 'Game Over';
      if (catSubEl) catSubEl.textContent = `${this.activeConfig.category} • Terminated (3 Mistakes)`;
    } else {
      if (badgeEl) badgeEl.textContent = '🏆';
      if (titleEl) titleEl.textContent = 'Session Complete!';
      if (catSubEl) catSubEl.textContent = this.activeConfig.category;
    }

    document.getElementById('res-score').textContent = `${score} pts`;
    document.getElementById('res-correct').textContent = `${this.sessionCorrect} Correct (out of ${total})`;
    const attempted = this.attempts.length;
    const acc = attempted > 0 ? ((this.sessionCorrect / attempted) * 100).toFixed(1) : '0';
    document.getElementById('res-accuracy').textContent = `${acc}%`;
    const spd = attempted > 0 ? (duration / attempted).toFixed(1) : '0';
    document.getElementById('res-speed').textContent = `${spd} s/Q`;

    this.showScreen('screen-results');
  }

  renderReviewScreen(filter = 'all') {
    const list = document.getElementById('review-cards-list');
    if (!list) return;

    let items = this.attempts;
    if (filter === 'wrong') items = this.attempts.filter(a => !a.isCorrect);
    if (filter === 'correct') items = this.attempts.filter(a => a.isCorrect);

    document.getElementById('chip-filter-all').textContent = `All (${this.attempts.length})`;
    document.getElementById('chip-filter-wrong').textContent = `Wrong (${this.attempts.filter(a => !a.isCorrect).length})`;
    document.getElementById('chip-filter-correct').textContent = `Correct (${this.attempts.filter(a => a.isCorrect).length})`;

    if (items.length === 0) {
      list.innerHTML = `<div class="card text-center" style="padding:40px;">No questions found under this filter.</div>`;
      return;
    }

    list.innerHTML = items.map((a, i) => {
      const q = a.question;
      const isCor = a.isCorrect;
      return `
        <div class="review-card">
          <div class="review-head">
            <span class="q-pill" style="background:${isCor ? 'var(--pastel-green)' : 'var(--pastel-pink)'}">
              Q${this.attempts.indexOf(a) + 1}
            </span>
            <span style="font-size:13px; font-weight:700; color:${isCor ? 'var(--success-green)' : 'var(--error-red)'}">
              ${isCor ? '✓ Correct' : '✕ Incorrect'}
            </span>
          </div>
          <div class="review-expr">${q.expr}</div>
          <div class="review-answers-compare">
            <div class="ans-box" style="background:${isCor ? 'rgba(188,232,163,0.3)' : 'rgba(255,183,176,0.3)'}">
              <span class="text-sub">Your Answer:</span>
              <strong style="color:${isCor ? 'var(--success-green)' : 'var(--error-red)'}">${a.selected}</strong>
            </div>
            <div class="ans-box" style="background:rgba(188,232,163,0.3)">
              <span class="text-sub">Correct Answer:</span>
              <strong style="color:var(--success-green)">${q.ans}</strong>
            </div>
          </div>
          ${q.explanation ? `
            <div class="review-explanation">
              <strong>💡 Mental Shortcut & Logic:</strong><br>
              ${q.explanation.replace(/\n/g, '<br>')}
            </div>
          ` : ''}
        </div>
      `;
    }).join('');
  }

  renderProgressDashboard() {
    const s = store.getStats();
    document.getElementById('stat-sessions').textContent = s.totalSessions;
    document.getElementById('stat-accuracy').textContent = `${s.avgAccuracy}%`;
    document.getElementById('stat-questions').textContent = s.totalQuestions;
    document.getElementById('stat-time').textContent = `${s.totalMinutes}m`;

    const breakdown = document.getElementById('category-breakdown-list');
    const cats = Object.entries(s.categoryMap);
    if (cats.length === 0) {
      breakdown.innerHTML = `<p class="text-sub">Complete practice sessions to unlock category accuracy charts.</p>`;
    } else {
      breakdown.innerHTML = cats.map(([name, data]) => {
        const pct = data.total > 0 ? ((data.correct / data.total) * 100).toFixed(0) : 0;
        return `
          <div class="breakdown-row">
            <div class="flex-between">
              <strong>${name}</strong>
              <span class="text-sub">${pct}% (${data.correct}/${data.total})</span>
            </div>
            <div class="progress-bar-bg" style="margin:4px 0;">
              <div class="progress-bar-fill" style="width:${pct}%; background:${pct >= 70 ? 'var(--success-green)' : 'var(--primary-orange)'}"></div>
            </div>
          </div>
        `;
      }).join('');
    }

    const recent = document.getElementById('recent-sessions-list');
    if (s.recent.length === 0) {
      recent.innerHTML = `<p class="text-sub">No recent sessions yet.</p>`;
    } else {
      recent.innerHTML = s.recent.map(r => {
        const d = r.date ? r.date.substring(0, 10) : '';
        const acc = r.totalQuestions > 0 ? ((r.correctAnswers / r.totalQuestions) * 100).toFixed(0) : 0;
        return `
          <div class="session-tile">
            <div>
              <strong>${r.category}</strong>
              <p class="text-sub">${d} • ${r.durationSeconds}s</p>
            </div>
            <div style="text-align:right;">
              <strong style="color:var(--primary-orange);">${r.score} pts</strong>
              <p style="font-size:12px; color:${acc >= 70 ? 'var(--success-green)' : 'var(--error-red)'};">${acc}% (${r.correctAnswers}/${r.totalQuestions})</p>
            </div>
          </div>
        `;
      }).join('');
    }
  }

  renderProfileScreen() {
    document.getElementById('profile-display-name').textContent = store.prefs.displayName;
    document.getElementById('profile-avatar-char').textContent = (store.prefs.displayName[0] || 'A').toUpperCase();
    document.getElementById('profile-level-badge').textContent = `Level: ${store.prefs.currentLevel}`;

    document.getElementById('toggle-three-wrong').checked = store.prefs.threeWrongRestartEnabled;
    document.getElementById('slider-threshold').value = store.prefs.wrongAnswerThreshold;
    document.getElementById('threshold-display').textContent = `${store.prefs.wrongAnswerThreshold} Mistakes`;

    document.getElementById('select-daily-goal').value = store.prefs.dailyGoalMinutes;
    document.getElementById('toggle-sound').checked = store.prefs.soundEnabled;
    document.getElementById('toggle-haptics').checked = store.prefs.hapticsEnabled;

    const exams = ['SSC', 'Banking', 'Railway', 'State Govt', 'Other'];
    const container = document.getElementById('profile-exams-group');
    container.innerHTML = exams.map(e => `
      <button class="chip ${store.prefs.examGoals.includes(e) ? 'active' : ''}" data-exam="${e}">${e}</button>
    `).join('');

    container.querySelectorAll('.chip').forEach(btn => {
      btn.addEventListener('click', () => {
        const e = btn.dataset.exam;
        if (store.prefs.examGoals.includes(e)) {
          store.prefs.examGoals = store.prefs.examGoals.filter(x => x !== e);
        } else {
          store.prefs.examGoals.push(e);
        }
        store.savePrefs();
        this.renderProfileScreen();
      });
    });
  }

  // --- EVENT BINDINGS ---
  bindEvents() {
    // Bottom Nav
    document.querySelectorAll('.nav-item').forEach(btn => {
      btn.addEventListener('click', () => {
        this.switchTab(btn.dataset.tab);
      });
    });

    // Profile Avatar Button in Header
    const avatarBtn = document.getElementById('btn-profile-avatar');
    if (avatarBtn) avatarBtn.addEventListener('click', () => this.switchTab('profile'));

    // Rapid Blitz Banner
    const blitz = document.getElementById('btn-rapid-blitz');
    if (blitz) {
      blitz.addEventListener('click', () => {
        this.activeConfig.category = 'Mixed Practice';
        this.activeConfig.timerSeconds = 60;
        this.activeConfig.questionCount = 20;
        this.startSession();
      });
    }

    // Config Back & Start
    document.getElementById('btn-config-back').addEventListener('click', () => {
      this.switchTab(this.currentTab);
    });
    document.getElementById('btn-start-session').addEventListener('click', () => {
      this.startSession();
    });

    // Config Sliders & Chips
    document.querySelectorAll('#config-difficulty .chip').forEach(c => {
      c.addEventListener('click', () => {
        document.querySelectorAll('#config-difficulty .chip').forEach(x => x.classList.remove('active'));
        c.classList.add('active');
        this.activeConfig.difficulty = c.dataset.val;
      });
    });

    document.getElementById('config-timer-slider').addEventListener('input', e => {
      this.activeConfig.timerSeconds = parseInt(e.target.value);
      document.getElementById('config-timer-val').textContent = `${e.target.value} s`;
    });

    const countSlider = document.getElementById('config-count-slider');
    if (countSlider) {
      countSlider.addEventListener('input', e => {
        this.activeConfig.questionCount = parseInt(e.target.value);
        const countVal = document.getElementById('config-count-val');
        if (countVal) countVal.textContent = `${e.target.value} Qs`;
      });
    }

    // Mental Flashing Controls
    document.querySelectorAll('#mental-speed-group .pill-sm').forEach(p => {
      p.addEventListener('click', () => {
        document.querySelectorAll('#mental-speed-group .pill-sm').forEach(x => x.classList.remove('active'));
        p.classList.add('active');
        this.mentalSpeed = parseFloat(p.dataset.speed);
      });
    });
    document.getElementById('btn-mental-replay').addEventListener('click', () => {
      this.playMentalQuestion();
    });

    // Results Actions
    document.getElementById('btn-review-answers').addEventListener('click', () => {
      this.renderReviewScreen('all');
      this.showScreen('screen-review');
    });
    document.getElementById('btn-practice-again').addEventListener('click', () => {
      this.startSession();
    });
    const resBack = document.getElementById('btn-results-back');
    if (resBack) {
      resBack.addEventListener('click', () => {
        this.switchTab('home');
      });
    }
    const resNavBack = document.getElementById('btn-results-nav-back');
    if (resNavBack) {
      resNavBack.addEventListener('click', () => {
        this.switchTab('home');
      });
    }

    // Review Filters & Back
    document.getElementById('btn-review-back').addEventListener('click', () => {
      this.showScreen('screen-results');
    });
    document.getElementById('btn-review-done').addEventListener('click', () => {
      this.switchTab('home');
    });
    document.querySelectorAll('.review-filter-row .chip').forEach(c => {
      c.addEventListener('click', () => {
        document.querySelectorAll('.review-filter-row .chip').forEach(x => x.classList.remove('active'));
        c.classList.add('active');
        this.renderReviewScreen(c.dataset.filter);
      });
    });

    // Profile Toggles & Sliders
    document.getElementById('toggle-three-wrong').addEventListener('change', e => {
      store.prefs.threeWrongRestartEnabled = e.target.checked;
      store.savePrefs();
    });
    document.getElementById('slider-threshold').addEventListener('input', e => {
      store.prefs.wrongAnswerThreshold = parseInt(e.target.value);
      document.getElementById('threshold-display').textContent = `${e.target.value} Mistakes`;
      store.savePrefs();
    });
    document.getElementById('select-daily-goal').addEventListener('change', e => {
      store.prefs.dailyGoalMinutes = parseInt(e.target.value);
      store.savePrefs();
    });
    document.getElementById('toggle-sound').addEventListener('change', e => {
      store.prefs.soundEnabled = e.target.checked;
      store.savePrefs();
    });
    document.getElementById('toggle-haptics').addEventListener('change', e => {
      store.prefs.hapticsEnabled = e.target.checked;
      store.savePrefs();
    });

    document.getElementById('btn-edit-name').addEventListener('click', () => {
      const name = prompt('Enter your name:', store.prefs.displayName);
      if (name && name.trim()) {
        store.prefs.displayName = name.trim();
        store.savePrefs();
        this.renderProfileScreen();
      }
    });

    document.getElementById('btn-clear-history').addEventListener('click', () => {
      if (confirm('Clear all session history records?')) {
        store.clearSessions();
        alert('History cleared.');
      }
    });

    document.getElementById('btn-reset-all').addEventListener('click', () => {
      if (confirm('Reset all progress, settings, and start over?')) {
        store.resetAll();
        location.reload();
      }
    });

    // Onboarding Events
    let onbStep = 0;
    const pages = document.querySelectorAll('.onboarding-page');
    const dots = document.querySelectorAll('.dots-indicator .dot');
    const btnNext = document.getElementById('btn-next-onboarding');

    const updateOnboarding = () => {
      pages.forEach((p, idx) => p.classList.toggle('active', idx === onbStep));
      dots.forEach((d, idx) => d.classList.toggle('active', idx === onbStep));
      btnNext.textContent = onbStep === pages.length - 1 ? 'Start Practising' : 'Continue';
    };

    btnNext.addEventListener('click', () => {
      if (onbStep < pages.length - 1) {
        onbStep++;
        updateOnboarding();
      } else {
        store.prefs.hasCompletedOnboarding = true;
        store.savePrefs();
        this.switchTab('home');
      }
    });

    document.getElementById('btn-skip-onboarding').addEventListener('click', () => {
      store.prefs.hasCompletedOnboarding = true;
      store.savePrefs();
      this.switchTab('home');
    });

    // Level selection
    document.querySelectorAll('#onboard-level .select-card').forEach(c => {
      c.addEventListener('click', () => {
        document.querySelectorAll('#onboard-level .select-card').forEach(x => x.classList.remove('active'));
        c.classList.add('active');
        store.prefs.currentLevel = c.dataset.val;
        document.getElementById('sum-level').textContent = c.dataset.val;
      });
    });

    // Daily goal choice
    document.querySelectorAll('#onboard-daily .choice-btn').forEach(b => {
      b.addEventListener('click', () => {
        document.querySelectorAll('#onboard-daily .choice-btn').forEach(x => x.classList.remove('active'));
        b.classList.add('active');
        store.prefs.dailyGoalMinutes = parseInt(b.dataset.val);
        document.getElementById('sum-goal').textContent = `${b.dataset.val} mins/day`;
      });
    });

    // QR Modal logic for desktop companion
    const btnShowQr = document.getElementById('btn-show-qr');
    const modalQr = document.getElementById('modal-qr');
    const btnCloseQr = document.getElementById('btn-close-qr');
    if (btnShowQr && modalQr) {
      btnShowQr.addEventListener('click', () => {
        const url = window.location.href;
        const qrContainer = document.getElementById('qr-code-img');
        qrContainer.innerHTML = `<img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(url)}" alt="QR Code" />`;
        document.getElementById('qr-url-text').textContent = url;
        modalQr.classList.remove('hidden');
      });
      btnCloseQr.addEventListener('click', () => {
        modalQr.classList.add('hidden');
      });
    }
  }
}

// Instantiate on DOM load
window.addEventListener('DOMContentLoaded', () => {
  new AppController();
});
