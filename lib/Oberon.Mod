MODULE Oberon;
  IMPORT Display, Texts;

  VAR Log*: Texts.Text;
    Par*: RECORD text*: Texts.Text; pos*: INTEGER END;

  PROCEDURE OpenLog*(T: Texts.Text);
  BEGIN Log := T
  END OpenLog;

  PROCEDURE GetSelection*(VAR text: Texts.Text; VAR beg, end, time: INTEGER);
  BEGIN time := -1
  END GetSelection;

  PROCEDURE SetPar*(F: Display.Frame; T: Texts.Text; pos: INTEGER);
  BEGIN NEW(Par.text); Par.pos := pos
  END SetPar;

  PROCEDURE Collect*(count: INTEGER);
  BEGIN
  END Collect;

END Oberon.

