MODULE Lola;
  IMPORT LSC, LSV, Display, Texts, Oberon;

  VAR F: Display.Frame; T: Texts.Text;

BEGIN
  Oberon.SetPar(F, T, 1); LSC.Compile;
  Oberon.SetPar(F, T, 2); LSV.List
END Lola.
