PROGRAM	"aocday25"
VERSION	"0.0000"

IMPORT	"xst"
IMPORT  "xma"

DECLARE FUNCTION  Entry ()
DECLARE FUNCTION  SnafuToDec (STRING value)
DECLARE FUNCTION  DecToSnafu (STRING value)

FUNCTION  Entry ()
  XstClearConsole()
  
  sum& = 0
  
  ifile$ = "input.txt"
  ifile = OPEN (ifile$, $$RD)
  lof = LOF (ifile)
  raw$ = NULL$ (lof)
  READ [ifile], raw$
  bytes = LEN (raw$)
  value$ = ""

  FOR offset = 0 TO bytes-1:
    byte@@ = raw${offset}
    IF byte@@ == 10 THEN
      sum& = sum& + SnafuToDec (value$)
    ELSE
      value$ = value$ + STRING (CHR$ (byte@@))
    END IF
  NEXT offset

  PRINT DecToSnafu (sum&)
END FUNCTION

FUNCTION  SnafuToDec (STRING value)
  length& = LEN (value)
  res& = 0

  FOR i% = 0 TO length& - 1
    exp& = length& - i% - 1
    char = value{i%}

    k& = 0
    SELECT CASE TRUE
      CASE (char = '-') : k& = -1
      CASE (char = '=') : k& = -2
      CASE ELSE : k& = SBYTE (CHR$ (char))
    END SELECT

    res& = res& + (5 ** exp& * k&)
  NEXT i%

  RETURN res&
END FUNCTION


FUNCTION  DecToSnafu (STRING value)
  val& = SLONG(value)
  res$ = ""
  carry& = 0

  DO WHILE (val& > 0)
    v& = val& MOD 5 + carry&
    IF v& <= 2 THEN
      carry& = 0
    ELSE
      carry& = 1
    END IF

    SELECT CASE TRUE
      CASE v& == 3: res$ = "=" + res$
      CASE v& == 4: res$ = "-" + res$
      CASE v& == 5: res$ = "0" + res$
      CASE ELSE: res$ = STRING (v&) + res$
    END SELECT

    val& = val& \ 5
  LOOP

  RETURN res$
END FUNCTION

END PROGRAM
