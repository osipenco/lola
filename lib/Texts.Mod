MODULE Texts;  (*OM 12.12.25*)
  IMPORT Files, Fonts, x86Out, x86Args;

  CONST Inval* = 0; Name* = 1; String* = 2; Int* = 3; Real* = 4; Char* = 6;

  TYPE Piece = POINTER TO PieceDesc;
    PieceDesc = RECORD
      f: Files.File;
      off, len: INTEGER;
      fnt: Fonts.Font;
      col, voff: INTEGER;
      prev, next: Piece
    END;

    Text* = POINTER TO TextDesc;
    Notifier* = PROCEDURE (T: Text; op: INTEGER; beg, end: INTEGER);
    TextDesc* = RECORD
      len*: INTEGER;
      changed*: BOOLEAN;
      notify*: Notifier;
      trailer: Piece;
      pce: Piece;
      org: INTEGER
    END;

    Reader* = RECORD
      eot*: BOOLEAN;
      fnt*: Fonts.Font;
      col*, voff*: INTEGER;
      ref: Piece;
      org: INTEGER;
      off: INTEGER;
      rider: Files.Rider
    END;

    Scanner* = RECORD (Reader)
      nextCh*: CHAR;
      line*, class*, i*: INTEGER;
      x*: REAL;
      c*: CHAR;
      len*: INTEGER;
      s*: ARRAY 32 OF CHAR
    END;

    Buffer* = POINTER TO BufDesc;
    BufDesc* = RECORD
      len*, last: INTEGER;
      header: ARRAY 4096 OF CHAR
    END;

    Writer* = RECORD
      buf*: Buffer;
      fnt*: Fonts.Font;
      col*, voff*: INTEGER;
      rider: Files.Rider
    END;

  PROCEDURE Open*(t: Text; name: ARRAY OF CHAR);
  BEGIN NEW(t.pce); t.pce.f := Files.Old(name)
  END Open;

  PROCEDURE Delete*(t: Text; beg, end: INTEGER);
  BEGIN
  END Delete;

  PROCEDURE Insert*(t: Text; pos: INTEGER; b: Buffer);
  BEGIN
  END Insert;

  PROCEDURE Copy*(SB, DB: Buffer);
  BEGIN
  END Copy;

  PROCEDURE Append*(t: Text; b: Buffer);
  BEGIN x86Out.String(b.header); b.header[0] := 0X; b.last := 0
  END Append;

  PROCEDURE ChangeLooks*(T: Text; beg, end: INTEGER; sel: SET; fnt: Fonts.Font; col, voff: INTEGER);
  BEGIN
  END ChangeLooks;

  PROCEDURE OpenReader*(VAR r: Reader; t: Text; pos: INTEGER);
  BEGIN Files.Set(r.rider, t.pce.f, pos); r.eot := FALSE
  END OpenReader;

  PROCEDURE Read*(VAR r: Reader; VAR ch: CHAR);
  BEGIN Files.Read(r.rider, ch); r.eot := r.rider.eof
  END Read;

  PROCEDURE Pos*(VAR r: Reader): INTEGER;
  BEGIN RETURN Files.Pos(r.rider)
  END Pos;

  PROCEDURE OpenScanner*(VAR S: Scanner; t: Text; pos: INTEGER);
  BEGIN S.line := pos
  END OpenScanner;

  PROCEDURE Scan*(VAR S: Scanner);
    VAR j: INTEGER;
  BEGIN x86Args.GetArg(S.line, S.s); INC(S.line); j := 0;
    IF ("A" <= S.s[0]) & (S.s[0] <= "Z") OR ("a" <= S.s[0]) & (S.s[0] <= "z") THEN S.class := Name
    ELSIF S.s[0] = 22X THEN S.class := String
  (*ELSIF ...*)
    ELSE S.class := Char; S.c := S.s[0]
    END
  END Scan;

  PROCEDURE OpenWriter*(VAR w: Writer);
  BEGIN NEW(w.buf); w.buf.last := 0
  END OpenWriter;

  PROCEDURE SetFont*(VAR w: Writer; fnt: Fonts.Font);
  BEGIN
  END SetFont;

  PROCEDURE SetColor*(VAR w: Writer; col: INTEGER);
  BEGIN
  END SetColor;

  PROCEDURE SetOffset*(VAR w: Writer; voff: INTEGER);
  BEGIN
  END SetOffset;

  PROCEDURE Write*(VAR w: Writer; ch: CHAR);
  BEGIN w.buf.header[w.buf.last] := ch; INC(w.buf.last)
  END Write;

  PROCEDURE WriteLn*(VAR w: Writer);
  BEGIN w.buf.header[w.buf.last] := 0AX; INC(w.buf.last)
  END WriteLn;

  PROCEDURE WriteString*(VAR w: Writer; s: ARRAY OF CHAR);
    VAR i: INTEGER;
  BEGIN i := 0;
    WHILE s[i] # 0X DO
      w.buf.header[w.buf.last] := s[i]; INC(w.buf.last); INC(i)
    END
  END WriteString;

  PROCEDURE WriteInt*(VAR W: Writer; x, n: INTEGER);
    VAR i, x0: INTEGER; a: ARRAY 10 OF CHAR;
  BEGIN i := 0;
    IF x < 0 THEN DEC(n); x0 := -x ELSE x0 := x END;
    REPEAT a[i] := CHR(x0 MOD 10 + 30H); x0 := x0 DIV 10; INC(i)
    UNTIL x0 = 0;
    WHILE n > i DO Write(W, " "); DEC(n) END;
    IF x < 0 THEN Write(W, "-") END;
    REPEAT DEC(i); Write(W, a[i]) UNTIL i = 0
  END WriteInt;

  PROCEDURE WriteHex*(VAR w: Writer; x: INTEGER);
  BEGIN
  END WriteHex;

  PROCEDURE WriteReal*(VAR w: Writer; x: REAL; n: INTEGER);
  BEGIN
  END WriteReal;

  PROCEDURE WriteRealFix*(VAR w: Writer; x: REAL; n, k: INTEGER);
  BEGIN
  END WriteRealFix;

  PROCEDURE WriteClock* (VAR W: Writer; d: INTEGER);
  BEGIN
  END WriteClock;

  PROCEDURE Load*(VAR r: Files.Rider; t: Text);
  BEGIN
  END Load;

  PROCEDURE Store*(VAR r: Files.Rider; t: Text);
  BEGIN
  END Store;

END Texts.
