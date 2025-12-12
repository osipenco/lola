MODULE Files;  (*OM 12.12.25*)
  IMPORT SYSTEM, FileDir, x86File;

  TYPE File* = INTEGER;  (*descriptor*)
    Buffer = POINTER TO BufferRecord;
    BufferRecord = RECORD apos, lim: INTEGER;
      mod: BOOLEAN;
      next: Buffer;
      data: FileDir.DataSector
    END;

    Rider* = RECORD
      eof*: BOOLEAN;
      res*: INTEGER;
      file: File;
      apos, bpos: INTEGER;
      buf: Buffer
    END;

  PROCEDURE Old*(name: ARRAY OF CHAR): File;
  BEGIN RETURN x86File.Open(name, "r+b")
  END Old;

  PROCEDURE New*(name: ARRAY OF CHAR): File;
  BEGIN RETURN x86File.Create(name)
  END New;

  PROCEDURE Register*(f: File);
  BEGIN x86File.Close(f)
  END Register;

  PROCEDURE Close*(f: File);
  BEGIN x86File.Close(f)
  END Close;

  PROCEDURE Purge*(f: File);
  BEGIN
  END Purge;

  PROCEDURE Length*(f: File): INTEGER;
  BEGIN RETURN 1
  END Length;

  PROCEDURE Date*(f: File): INTEGER;
  BEGIN RETURN 1
  END Date;

  PROCEDURE Set*(VAR r: Rider; f: File; pos: INTEGER);
  BEGIN IF x86File.Seek(f, pos, 0) = 0 THEN r.eof := FALSE; r.file := f END
  END Set;

  PROCEDURE Pos*(VAR r: Rider): INTEGER;
  BEGIN RETURN x86File.Pos(r.file)
  END Pos;

  PROCEDURE Base*(VAR r: Rider): File;
  BEGIN RETURN r.file
  END Base;

  PROCEDURE ReadByte*(VAR r: Rider; VAR x: BYTE);
  BEGIN IF x86File.Read(r.file, SYSTEM.ADR(x), 1) = 0 THEN r.eof := TRUE END
  END ReadByte;

  PROCEDURE ReadBytes*(VAR r: Rider; VAR x: ARRAY OF BYTE; n: INTEGER);
  BEGIN IF x86File.Read(r.file, SYSTEM.ADR(x), n) < n THEN r.eof := TRUE END
  END ReadBytes;

  PROCEDURE Read*(VAR r: Rider; VAR ch: CHAR);
  BEGIN IF x86File.Read(r.file, SYSTEM.ADR(ch), 1) = 0 THEN r.eof := TRUE END
  END Read;

  PROCEDURE ReadInt*(VAR R: Rider; VAR x: INTEGER);
    VAR Buf: ARRAY 8 OF BYTE;
  BEGIN ReadBytes(R, Buf, 8);  (*little-endian*)
    x := (((((((Buf[7] * 100H + Buf[6]) * 100H + Buf[5]) * 100H + Buf[4])
      * 100H + Buf[3]) * 100H + Buf[2]) * 100H + Buf[1]) * 100H + Buf[0])
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
      IF i < LEN(x)-1 THEN x[i] := ch; INC(i) END;
      Read(R, ch)
    END;
    x[i] := 0X
  END ReadString;

  PROCEDURE ReadNum*(VAR R: Rider; VAR x: INTEGER);
  BEGIN
  END ReadNum;

  PROCEDURE WriteByte*(VAR r: Rider; x: BYTE);
  BEGIN IF x86File.Write(r.file, SYSTEM.ADR(x), 1) > 0 THEN r.eof := FALSE END
  END WriteByte;

  PROCEDURE WriteBytes*(VAR r: Rider; x: ARRAY OF BYTE; n: INTEGER);
  BEGIN IF x86File.Write(r.file, SYSTEM.ADR(x), n) > 0 THEN r.eof := FALSE END
  END WriteBytes;

  PROCEDURE Write*(VAR r: Rider; ch: CHAR);
  BEGIN IF x86File.Write(r.file, SYSTEM.ADR(ch), 1) > 0 THEN r.eof := FALSE END
  END Write;

  PROCEDURE WriteInt*(VAR R: Rider; x: INTEGER);
    VAR Buf: ARRAY 8 OF BYTE;
  BEGIN Buf[0] := x MOD 100H;
    Buf[1] := x DIV 100H MOD 100H;
    Buf[2] := x DIV 10000H MOD 100H;
    Buf[3] := x DIV 1000000H MOD 100H;
    Buf[4] := x DIV 100000000H MOD 100H;
    Buf[5] := x DIV 10000000000H MOD 100H;
    Buf[6] := x DIV 1000000000000H MOD 100H;
    Buf[7] := x DIV 100000000000000H MOD 100H;
    WriteBytes(R, Buf, 8)  (*little-endian*)
  END WriteInt;

  PROCEDURE WriteSet*(VAR R: Rider; s: SET);
  BEGIN WriteInt(R, ORD(s))
  END WriteSet;

  PROCEDURE WriteReal*(VAR R: Rider; x: REAL);
  BEGIN
  END WriteReal;

  PROCEDURE WriteString*(VAR R: Rider; x: ARRAY OF CHAR);
    VAR i: INTEGER; ch: CHAR;
  BEGIN i := 0;
    REPEAT ch := x[i]; Write(R, ch); INC(i) UNTIL ch = 0X
  END WriteString;

  PROCEDURE WriteNum*(VAR R: Rider; x: INTEGER);
  BEGIN
  END WriteNum;

  PROCEDURE Delete*(name: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN IF x86File.Delete(name) THEN res := 0 END
  END Delete;

  PROCEDURE Rename*(old, new: ARRAY OF CHAR; VAR res: INTEGER);
  BEGIN
  END Rename;

END Files.
