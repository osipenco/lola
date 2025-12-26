MODULE Files;
  IMPORT SYSTEM, x86File;

  TYPE File* = INTEGER;  (*FileDesc*)
    Rider* = RECORD eof*: BOOLEAN; res*: INTEGER; file: File END;

  PROCEDURE Old*(name: ARRAY OF CHAR): File;
  BEGIN RETURN x86File.fopen(SYSTEM.ADR(name[0]), SYSTEM.SADR("r+b"))
  END Old;

  PROCEDURE New*(name: ARRAY OF CHAR): File;
  BEGIN RETURN x86File.fopen(SYSTEM.ADR(name[0]), SYSTEM.SADR("wb"))
  END New;

  PROCEDURE Register*(f: File);
  BEGIN
  END Register;

  PROCEDURE Close*(f: File);
  BEGIN IF f > 0 THEN f := x86File.fclose(f) END
  END Close;

  PROCEDURE Purge*(f: File);
  BEGIN IF f > 0 THEN f := x86File.ftruncate(x86File.fileno(f), 0) END
  END Purge;

  PROCEDURE Delete*(name: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN res := x86File.remove(SYSTEM.ADR(name[0]))
  END Delete;

  PROCEDURE Rename*(old, new: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN res := x86File.rename(SYSTEM.ADR(old[0]), SYSTEM.ADR(new[0]))
  END Rename;

  PROCEDURE Length*(f: File): INTEGER;
    VAR pos, len: INTEGER;
  BEGIN pos := x86File.ftell(f); len := x86File.fseek(f, 0, 2);
    len := x86File.ftell(f); pos := x86File.fseek(f, pos, 0)
    RETURN len
  END Length;

  PROCEDURE Set*(VAR r: Rider; f: File; pos: INTEGER);
  BEGIN
    IF f > 0 THEN
      IF pos < 0 THEN pos := 0 ELSIF pos > Length(f) THEN pos := Length(f) END;
      r.res := x86File.fseek(f, pos, 0)
    END;
    r.eof := FALSE; r.res := 0; r.file := f
  END Set;

  PROCEDURE Pos*(VAR r: Rider): INTEGER;
  BEGIN RETURN x86File.ftell(r.file)
  END Pos;

  PROCEDURE Base*(VAR r: Rider): File;
  BEGIN RETURN r.file
  END Base;

  PROCEDURE ReadByte*(VAR r: Rider; VAR x: BYTE);
  BEGIN IF x86File.fread(SYSTEM.ADR(x), 1, 1, r.file) < 1 THEN x := 0; r.eof := TRUE END
  END ReadByte;

  PROCEDURE ReadBytes*(VAR r: Rider; VAR x: ARRAY OF BYTE; n: INTEGER);
    VAR i: INTEGER; b: BYTE;
  BEGIN i := 0;
    WHILE i < n DO ReadByte(r, b);
      IF i < LEN(x) THEN x[i] := b END;
      INC(i)
    END
  END ReadBytes;

  PROCEDURE Read*(VAR r: Rider; VAR ch: CHAR);
    VAR b: BYTE;
  BEGIN ReadByte(r, b); ch := CHR(b)
  END Read;

  PROCEDURE ReadInt*(VAR R: Rider; VAR x: INTEGER);
    VAR buf: ARRAY 8 OF BYTE;
  BEGIN ReadBytes(R, buf, 8);
    x := ((((((buf[0]
      * 100H + buf[1])
      * 100H + buf[2])
      * 100H + buf[3])
      * 100H + buf[4])
      * 100H + buf[5])
      * 100H + buf[6])
      * 100H + buf[7]  (*LE*)
  END ReadInt;

  PROCEDURE ReadSet*(VAR R: Rider; VAR s: SET);
  BEGIN ReadInt(R, SYSTEM.VAL(INTEGER, s))
  END ReadSet;

  PROCEDURE ReadReal*(VAR R: Rider; VAR x: REAL);
  BEGIN ReadInt(R, SYSTEM.VAL(INTEGER, x))
  END ReadReal;

  PROCEDURE ReadString*(VAR R: Rider; VAR x: ARRAY OF CHAR);
    VAR i: INTEGER; ch: CHAR;
  BEGIN i := 0; Read(R, ch);
    WHILE ch # 0X DO
      IF i < LEN(x) - 1 THEN x[i] := ch; INC(i) END;
      Read(R, ch)
    END;
    x[i] := 0X
  END ReadString;

  PROCEDURE ReadNum*(VAR R: Rider; VAR x: INTEGER);
    VAR n, y: INTEGER; b: BYTE;
  BEGIN n := 64; y := 0; ReadByte(R, b);
    WHILE b >= 80H DO y := ROR(y + b - 80H, 7); DEC(n, 7); ReadByte(R, b) END;
    IF n <= 4 THEN x := ROR(y + b MOD 10H, 4) ELSE x := ASR(ROR(y + b, 7), n - 7) END
  END ReadNum;

  PROCEDURE WriteByte*(VAR r: Rider; x: BYTE);
  BEGIN x := x86File.fwrite(SYSTEM.ADR(x), 1, 1, r.file)
  END WriteByte;

  PROCEDURE WriteBytes*(VAR r: Rider; x: ARRAY OF BYTE; n: INTEGER);
    VAR i: INTEGER;
  BEGIN i := 0;
    WHILE i < n DO
      IF i < LEN(x) THEN WriteByte(r, x[i]) ELSE WriteByte(r, 0) END;
      INC(i)
    END
  END WriteBytes;

  PROCEDURE Write*(VAR r: Rider; ch: CHAR);
  BEGIN WriteByte(r, ORD(ch))
  END Write;

  PROCEDURE WriteInt*(VAR R: Rider; x: INTEGER);
    VAR buf: ARRAY 8 OF BYTE;
  BEGIN
    buf[7] := x MOD 100H;  (*LE*)
    buf[6] := x DIV 100H MOD 100H;
    buf[5] := x DIV 10000H MOD 100H;
    buf[4] := x DIV 1000000H MOD 100H;
    buf[3] := x DIV 100000000H MOD 100H;
    buf[2] := x DIV 10000000000H MOD 100H;
    buf[1] := x DIV 1000000000000H MOD 100H;
    buf[0] := x DIV 100000000000000H MOD 100H;
    WriteBytes(R, buf, 8)
  END WriteInt;

  PROCEDURE WriteSet*(VAR R: Rider; s: SET);
  BEGIN WriteInt(R, ORD(s))
  END WriteSet;

  PROCEDURE WriteReal*(VAR R: Rider; x: REAL);
  BEGIN WriteInt(R, SYSTEM.VAL(INTEGER, x))
  END WriteReal;

  PROCEDURE WriteString*(VAR R: Rider; x: ARRAY OF CHAR);
    VAR i: INTEGER; ch: CHAR;
  BEGIN i := 0;
    REPEAT ch := x[i]; Write(R, ch); INC(i) UNTIL ch = 0X
  END WriteString;

  PROCEDURE WriteNum*(VAR R: Rider; x: INTEGER);
  BEGIN
    WHILE (x < -40H) OR (x >= 40H) DO WriteByte(R, x MOD 80H + 80H); x := ASR(x, 7) END;
    WriteByte(R, x MOD 80H)
  END WriteNum;

END Files.
