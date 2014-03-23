class SQLSearch::Parser

option
  ignorecase

macro
  BLANK  [\ \t]+
  STRING [^']+
  APPROXNUM {INTNUM}\.{INTNUM}
  INTNUM \d+
  COMPARISON (<>|=|[<][=]|[<]|[>][=]|[>])

  NAME [A-z_]([A-z0-9_]*)

  IS is
  NOT not
  NULLX null
  IN in
  OR or
  AND and
  BETWEEN between

  YEARS   \d+
  MONTHS  \d{2}
  DAYS    \d{2}
  HOURS   \d{2}
  MINUTES \d{2}
  SECONDS \d{2}
  UTC_OFFSET  ([+-]{HOURS}:{MINUTES}|Z)
  TIME    {YEARS}-{MONTHS}-{DAYS}T{HOURS}:{MINUTES}:{SECONDS}{UTC_OFFSET}

rule
  {BLANK}
  {APPROXNUM} { [:APPROXNUM, text.to_f] }
  {INTNUM} { [:INTNUM, text.to_i] }
  '{TIME}' { [:TIME, DateTime.iso8601(text[1...-1])] }
  '{STRING}' { [:STRING, text[1...-1]] }
  IS { [:IS, text] }
  NOT { [:NOT, text] }
  NULL { [:NULL, text.upcase] }
  IN { [:IN, text] }
  OR { [:OR, text] }
  AND { [:AND, text] }
  BETWEEN { [:BETWEEN, text] }
  LIKE { [:LIKE, text] }
  {COMPARISON} { [:COMPARISON, text] }
  {NAME} { [:NAME, text] }
  \( { [:LPAREN, text] }
  \) { [:RPAREN, text] }
  \. { [:DOT, text] }
  \, { [:COMMA, text] }
inner

  def tokenize(code)
    scan_setup(code)
    tokens = []
    while token = next_token
      tokens << token
    end
    tokens
  end
end
