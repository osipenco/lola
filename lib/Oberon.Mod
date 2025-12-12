MODULE Oberon;
  IMPORT Display, Viewers, Texts;

  VAR Log*: Texts.Text;
    Par*: RECORD
      vwr*: Viewers.Viewer;
      frame*: Display.Frame;
      text*: Texts.Text;
      pos*: INTEGER
    END;

  PROCEDURE OpenLog*(T: Texts.Text);
  BEGIN Log := T
  END OpenLog;

  PROCEDURE GetSelection*(VAR text: Texts.Text; VAR beg, end, time: INTEGER);
  BEGIN
  END GetSelection;

  PROCEDURE SetPar*(F: Display.Frame; T: Texts.Text; pos: INTEGER);
  BEGIN Par.vwr := Viewers.This(F.X, F.Y); Par.frame := F; Par.text := T; Par.pos := pos
  END SetPar;

END Oberon.

