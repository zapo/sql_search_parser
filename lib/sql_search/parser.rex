class SQLSearch::Parser

option
  ignorecase

macro
  TRUE (true|t)
  FALSE (false|f)
  BLANK [\ \t]+
  STRING (["'])(?:(?!\1)[^\\]|\\.)*\1
  APPROXNUM {INTNUM}\.{INTNUM}
  INTNUM \d+
  IS is
  NOT not
  COMPARISON ([<][>]|[=]|[<][=]|[<]|[>][=]|[>]|[!][=]|\b{IS}{BLANK}{NOT}\b|\b{IS}\b)

  NAME [A-z_]([A-z0-9_]*)

  YEARS   \d+
  MONTHS  \d{2}
  DAYS    \d{2}
  HOURS   \d{2}
  MINUTES \d{2}
  SECONDS \d{2}
  UTC_OFFSET  ([+-]{HOURS}:{MINUTES}|Z)
  TIME    (["']){YEARS}-{MONTHS}-{DAYS}T{HOURS}:{MINUTES}:{SECONDS}{UTC_OFFSET}\1

rule
  {BLANK}
  \b{APPROXNUM}\b { [:APPROXNUM, text.to_f] }
  \b{INTNUM}\b { [:INTNUM, text.to_i] }
  {TIME} { [:TIME, DateTime.iso8601(text[1...-1])] }
  {STRING} { [:STRING, text[1...-1]] }
  \bIN\b { [:IN, text] }
  \bOR\b { [:OR, text] }
  \bAND\b { [:AND, text] }
  \bBETWEEN\b { [:BETWEEN, text] }
  \bLIKE\b { [:LIKE, text] }
  {COMPARISON} { [:COMPARISON, text] }
  \b{NOT}\b { [:NOT, text] }
  \bNULL\b { [:NULL, nil] }
  \b{TRUE}\b { [:BOOL, true] }
  \b{FALSE}\b { [:BOOL, false] }
  \b{NAME}\b { [:NAME, text] }
  \( { [:LPAREN, text] }
  \) { [:RPAREN, text] }
  \. { [:DOT, text] }
  \, { [:COMMA, text] }
  \+ { [:ADD, text] }
  \- { [:SUBTRACT, text] }
  \/ { [:DIVIDE, text] }
  \* { [:MULTIPLY, text] }
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
