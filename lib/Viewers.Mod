MODULE Viewers;
  IMPORT Display;

  TYPE Viewer* = POINTER TO ViewerDesc;
    ViewerDesc* = RECORD (Display.FrameDesc) state*: INTEGER END;

  PROCEDURE This*(X, Y: INTEGER): Viewer;
    VAR V: Display.Frame;
  BEGIN RETURN V(Viewer)
  END This;

END Viewers.
