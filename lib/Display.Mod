MODULE Display;

  TYPE Frame* = POINTER TO FrameDesc;
    FrameMsg* = RECORD END;
    Handler* = PROCEDURE (F: Frame; VAR M: FrameMsg);
    FrameDesc* = RECORD next*, dsc*: Frame;
      X*, Y*, W*, H*: INTEGER;
      handle*: Handler
    END;

END Display.
