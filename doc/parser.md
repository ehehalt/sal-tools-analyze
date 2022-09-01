# Parser

## LineParser

Parst die Zeilen des Sourcecodes. Trenner ist das "Newline außerhalb eines Textes". Varianten sind z. B.

__Properties__

```
.head 0 +  Application Description: STRCI11.DLL
```

* ".head" = Head
* "0" = Level
* "+" = Child Indicator
* "Application Description" = Property Name
* ":" = Splitter
* "STRC11.DLL" = Value

```
.head 3 -  Visible? No
```

* "?" = Splitter

__Data__

```
.data VIEWINFO
0000: 6F00000001000000 FFFF01000D004347 5458566965775374 6174650400FFFFFF
0020: FF00000000250100 002C000000020000 0003000000FFFFFF FFFFFFFFFFFCFFFF
0040: FFE2FFFFFF010000 0005000000710200 0045010000010000 0000000000010000
0060: 000F4170706C6963 6174696F6E497465 6D00000000
.enddata
```

* ".data" = Head
* "VIEWINFO" = Property Name
* "0000..."
* ".enddate" = Head?

__Group__

```
.head 2 +  Class Editor Location
```

* "Class Editor Location" = Group Name

__Sourcecode__

```
.head 5 +  If hWndCol = hWndNULL
```

* "If hWndCol = hWndNULL" = Code

Befehlswörter (zur Code Erkennung):

* 