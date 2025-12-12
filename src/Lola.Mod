MODULE Lola;
  IMPORT LSC, LSV, Display, Texts, Oberon;

  VAR F: Display.Frame; T: Texts.Text;

BEGIN NEW(F); NEW(T);
  Oberon.SetPar(F, T, 1); LSC.Compile;
  Oberon.SetPar(F, T, 2); LSV.List
END Lola.
