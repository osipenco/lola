MODULE Texts;
  IMPORT SYSTEM, Files, x86Out, x86Args;

  CONST Inval* = 0; Name* = 1; String* = 2; Int* = 3; Real* = 4; Char* = 6;

  TYPE Text* = POINTER TO TextDesc;
    TextDesc* = RECORD len*: INTEGER; file: Files.File END;

    Reader* = RECORD eot*: BOOLEAN; rider: Files.Rider END;

    Scanner* = RECORD (Reader)
      nextCh*: CHAR;
      line*, class*, i*: INTEGER;
      x*: REAL;
      c*: CHAR;
      len*: INTEGER;
      s*: ARRAY 32 OF CHAR
    END;

    Buffer* = POINTER TO BufDesc;
    BufDesc* = RECORD len*: INTEGER END;

    Writer* = RECORD buf*: Buffer END;

  PROCEDURE Load*(VAR R: Files.Rider; T: Text);
  BEGIN
  END Load;

  PROCEDURE Open*(t: Text; name: ARRAY OF CHAR);
  BEGIN t.file := Files.Old(name);
    IF t.file > 0 THEN t.len := Files.Length(t.file) END
  END Open;

  PROCEDURE Store* (VAR W: Files.Rider; T: Text);
  BEGIN
  END Store;

  PROCEDURE Close*(t: Text; name: ARRAY OF CHAR);
  BEGIN Files.Close(t.file)
  END Close;

  PROCEDURE OpenBuf*(B: Buffer);
  BEGIN B.len := 0
  END OpenBuf;

  PROCEDURE Save*(T: Text; beg, end: INTEGER; B: Buffer);
  BEGIN
  END Save;

  PROCEDURE Copy*(SB, DB: Buffer);
  BEGIN
  END Copy;

  PROCEDURE Insert*(T: Text; pos: INTEGER; B: Buffer);
  BEGIN
  END Insert;

  PROCEDURE Append*(T: Text; B: Buffer);
  BEGIN
  END Append;

  PROCEDURE Delete*(T: Text; beg, end: INTEGER; B: Buffer);
  BEGIN
  END Delete;

  PROCEDURE OpenReader*(VAR r: Reader; t: Text; pos: INTEGER);
  BEGIN Files.Set(r.rider, t.file, pos); r.eot := FALSE
  END OpenReader;

  PROCEDURE Read*(VAR r: Reader; VAR ch: CHAR);
  BEGIN Files.Read(r.rider, ch); r.eot := r.rider.eof
  END Read;

  PROCEDURE Pos*(VAR r: Reader): INTEGER;
  BEGIN RETURN Files.Pos(r.rider)
  END Pos;

  PROCEDURE OpenScanner*(VAR S: Scanner; T: Text; pos: INTEGER);
  BEGIN S.line := pos; S.nextCh := " "
  END OpenScanner;

  PROCEDURE Ten(n: INTEGER): REAL;
    VAR t, p: REAL;
  BEGIN t := 1.0; p := 10.0;
    WHILE n > 0 DO
      IF ODD(n) THEN t := p * t END;
      p := p * p; n := n DIV 2
    END
    RETURN t
  END Ten;

  PROCEDURE Scan*(VAR S: Scanner);
    CONST maxExp = 308; maxM = 9007199254740992;
    VAR ch: CHAR;
      neg, negE, hex: BOOLEAN;
      i, j, h, d, e, n, s: INTEGER;
      x: REAL;
  BEGIN
    IF S.line > x86Args.argc - 1 THEN S.class := Inval
    ELSE x86Args.GetArg(S.line, S.s); INC(S.line); i := 0; ch := S.s[i];
      IF ("A" <= ch) & (ch <= "Z") OR ("a" <= ch) & (ch <= "z") THEN
        S.len := LEN(S.s); S.class := Name
      ELSIF ch = 22X THEN
        REPEAT S.s[i] := S.s[i + 1]; INC(i) UNTIL S.s[i] = 22X;
        S.s[i - 1] := 0X; S.len := LEN(S.s); S.class := String
      ELSE hex := FALSE;
        IF ch = "-" THEN neg := TRUE; INC(i); ch := S.s[i] ELSE neg := FALSE END;
        IF ("0" <= ch) & (ch <= "9") THEN
          n := ORD(ch) - 30H; h := n; INC(i); ch := S.s[i];
          WHILE ("0" <= ch) & (ch <= "9") OR ("A" <= ch) & (ch <= "F") DO
            IF ch <= "9" THEN d := ORD(ch) - 30H ELSE d := ORD(ch) - 37H; hex := TRUE END;
            n := 10 * n + d; h := 10H * h + d; INC(i); ch := S.s[i]
          END;
          IF ch = "H" THEN INC(i); ch := S.s[i]; S.i := h; S.class := Int
          ELSIF ch = "." THEN
            INC(i); ch := S.s[i]; x := 0.0; e := 0; j := 0;
            WHILE ("0" <= ch) & (ch <= "9") DO
              h := 10 * n + (ORD(ch) - 30H);
              IF h < maxM THEN n := h; INC(j) END;
              INC(i); ch := S.s[i]
            END;
            IF ch = "E" THEN
              s := 0; INC(i); ch := S.s[i];
              IF ch = "-" THEN negE := TRUE; INC(i); ch := S.s[i]
              ELSE negE := FALSE;
                IF ch = "+" THEN INC(i); ch := S.s[i] END
              END;
              WHILE ("0" <= ch) & (ch <= "9") DO
                s := s * 10 + ORD(ch) - 30H; INC(i); ch := S.s[i]
              END;
              IF negE THEN DEC(e, s) ELSE INC(e, s) END;
            END;
            x := FLT(n); DEC(e, j);
            IF e < 0 THEN
              IF e >= -maxExp THEN x := x / Ten(-e) ELSE x := 0.0 END
            ELSIF e > 0 THEN
              IF e <= maxExp THEN x := Ten(e) * x ELSE x := 0.0 END
            END;
            IF neg THEN S.x := -x ELSE S.x := x END;
            IF hex THEN S.class := Inval ELSE S.class := Real END
          ELSE
            IF neg THEN S.i := -n ELSE S.i := n END;
            IF hex THEN S.class := Inval ELSE S.class := Int END
          END
        ELSE S.class := Char;
          IF neg THEN S.c := "-" ELSE S.c := ch; INC(i); ch := S.s[i] END
        END
      END;
      S.nextCh := ch
    END
  END Scan;

  PROCEDURE OpenWriter*(VAR W: Writer);
  BEGIN NEW(W.buf); OpenBuf(W.buf)
  END OpenWriter;

  PROCEDURE Write*(VAR W: Writer; ch: CHAR);
  BEGIN x86Out.printf1(SYSTEM.SADR("%c"), ORD(ch))
  END Write;

  PROCEDURE WriteLn*(VAR W: Writer);
  BEGIN Write(W, 0AX)
  END WriteLn;

  PROCEDURE WriteString*(VAR W: Writer; s: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN i := 0;
    WHILE s[i] # 0X DO Write(W, s[i]); INC(i) END
  END WriteString;

  PROCEDURE WriteInt*(VAR W: Writer; x, n: INTEGER);
    VAR i: INTEGER; x0: INTEGER; a: ARRAY 19 OF CHAR;
  BEGIN i := 0;
    IF x < 0 THEN DEC(n); x0 := -x ELSE x0 := x END;
    REPEAT a[i] := CHR(x0 MOD 10 + 30H); x0 := x0 DIV 10; INC(i)
    UNTIL x0 = 0;
    WHILE n > i DO Write(W, " "); DEC(n) END;
    IF x < 0 THEN Write(W, "-") END;
    REPEAT DEC(i); Write(W, a[i]) UNTIL i = 0
  END WriteInt;

  PROCEDURE WriteHex*(VAR W: Writer; x: INTEGER);
    VAR i, y: INTEGER; a: ARRAY 16 OF CHAR;
  BEGIN i := 0;
    REPEAT y := x MOD 10H;
      IF y < 10 THEN a[i] := CHR(y + 30H) ELSE a[i] := CHR(y + 37H) END;
      x := x DIV 10H; INC(i)
    UNTIL i = 16;
    REPEAT DEC(i); Write(W, a[i]) UNTIL i = 0
  END WriteHex;

  PROCEDURE WriteReal*(VAR W: Writer; x: REAL; n: INTEGER);
    VAR e, i, k, m: INTEGER; d: ARRAY 19 OF CHAR;
  BEGIN e := ASR(SYSTEM.VAL(INTEGER, x), 52) MOD 800H;
    IF e = 0 THEN
      WHILE n > 3 DO Write(W, " "); DEC(n) END;
      WriteString(W, "0.0")
    ELSIF e = 2047 THEN WriteString(W, "NaN")
    ELSE
      WHILE n > 22 DO DEC(n); Write(W, " ") END;
      IF x < 0.0 THEN Write(W, "-"); x := -x END;
      e := (e - 1023) * 77 DIV 256 - 6;
      IF e >= 0 THEN x := x / Ten(e) ELSE x := Ten(-e) * x END;
      m := FLOOR(x + 0.5);
      IF m >= 1000000000000000 THEN INC(e); m := m DIV 10 END;
      i := 0; k := 20 - n;
      REPEAT
        IF i = k THEN INC(m, 5) END;
        d[i] := CHR(m MOD 10 + 30H); m := m DIV 10; INC(i)
      UNTIL m = 0;
      DEC(i); Write(W, d[i]); Write(W, ".");
      IF i < n - 15 THEN n := 0 ELSE n := 30 - n END;
      WHILE i > n DO DEC(i); Write(W, d[i]) END;
      Write(W, "E"); INC(e, 6);
      IF e < 0 THEN Write(W, "-"); e := -e ELSE Write(W, "+") END;
      Write(W, CHR(e DIV 100 + 30H));
      Write(W, CHR((e DIV 10) MOD 10 + 30H));
      Write(W, CHR(e MOD 10 + 30H))
    END
  END WriteReal;

  PROCEDURE WriteRealFix*(VAR W: Writer; x: REAL; n, k: INTEGER);
    VAR i, m: INTEGER; neg: BOOLEAN; d: ARRAY 19 OF CHAR;
  BEGIN
    IF x = 0.0 THEN Write(W, "0") END;
    IF x < 0.0 THEN x := -x; neg := TRUE ELSE neg := FALSE END;
    IF k > 15 THEN k := 15 ELSIF k < 1 THEN k := 1 END;
    x := Ten(k) * x; m := FLOOR(x + 0.5); i := 0;
    REPEAT d[i] := CHR(m MOD 10 + 30H); m := m DIV 10; INC(i) UNTIL m = 0;
    WHILE n >= i + 2 DO Write(W, " "); DEC(n) END;
    IF neg THEN Write(W, "-"); DEC(n) END;
    WHILE i > k DO DEC(i); Write(W, d[i]) END;
    Write(W, ".");
    WHILE k > i DO DEC(k); Write(W, "0") END;
    WHILE i > 0 DO DEC(i); Write(W, d[i]) END
  END WriteRealFix;

END Texts.
