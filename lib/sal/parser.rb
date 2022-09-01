# coding: utf-8

module Sal

	class Token
		attr_accessor :type, :text

		def initialize(type, text)
			@type = type
			@text = text
		end

		def to_s
			"<'#{@text}', #{@type}>"
		end
	end
	
	# LL(1) Recursive-Descent Lexer
	class LL1Lexer

		EOF = -1
		EOF_TYPE = 1

		attr_reader :input, :index, :last, :current

		def initialize(input)
			@input = input
			@index = 0 # index
			@last = EOF
			@current = @input[@index]
		end

		def consume()
			@index += 1
			@last = @current
			if(@index >= @input.length)
				@current = EOF
			else
				@current = @input[@index]
			end
		end

		def match(check)
			if(current == check)
				consume
			else
				raise "Expecting #{check}; Found #{current}"
			end
		end
	end

	# LL(1) Recursive-Descent Lexer
	class CodeLexer < LL1Lexer

		NAME     =  2
		COMMA    =  3
		LBRACK1  =  4 # (
		RBRACK1  =  5 # ) 
		LBRACK2  =  6 # {
		RBRACK2  =  7 # }
		STRING   =  8
		EQUAL    =  9
		NOT      = 10
		NOTEQUAL = 11
		OPERA    = 12

		def CodeLexer.get_tokens(input)
			lexer = CodeLexer.new(input)
			tokens = []
			token = lexer.next_token
			while(token.type != EOF_TYPE)
				tokens << token
				token = lexer.next_token
			end
			return tokens
		end

		def token_names
			["n/a", "<EOF>", "NAME", "COMMA", "LBRACK1", "RBRACK1", "LBRACK2", "RBRACK2", "STRING", "EQUAL", "NOT", "NOTEQUAL", "OPERA"]
		end

		def get_token_name(idx)
			token_names[idx]
		end

		def initialize(input)
			super(input)
		end

		def is_letter?
			letter1 = (@current >= 'a' and @current <= 'z')
			letter2 = (@current >= 'A' and @current <= 'Z')
			number  = (@current >= '0' and @current <= '9')
			return (letter1 or letter2 or number)
		end

		def is_operator?
			case @current
			when '|' then return true
			when '+' then return true
			when '-' then return true
			when '*' then return true
			when '/' then return true
			when '%' then return true
			when '&' then return true
			else return false
			end
		end

		def next_token
			while @current != EOF
				case @current
				when ' ' 	then ws
				when '\t' 	then ws
				when '\n' 	then ws
				when '\r' 	then ws
				when '=' 	then consume; return Token.new(EQUAL, "=")
				when '!'    then return get_not
				when ','	then consume; return Token.new(COMMA, ",")
				when '('	then consume; return Token.new(LBRACK1, "(")
				when ')'	then consume; return Token.new(RBRACK1, ")")
				when '['	then consume; return Token.new(LBRACK2, "[")
				when ']'	then consume; return Token.new(RBRACK2, "]")
				when '|'	then return get_operator
				when '+'	then return get_operator
				when '-'	then return get_operator
				when '*'	then return get_operator
				when '/'	then return get_operator
				when '%'	then return get_operator
				when '&'	then return get_operator
				when '\''	then return get_string
				when '"'	then return get_string
				else 		return get_name
				end
			end
			return Token.new(EOF_TYPE,"<EOF>")
		end

		def get_name
			buffer = ""
			loop do
				buffer += @current
				consume
				break if (!is_letter? or @current == EOF)
			end
			return Token.new(NAME, buffer)
		end

		def get_string
			buffer = ""
			quote = @current
			loop do
				buffer += @current
				consume
				break if (@current == quote and not(@current == quote and @last == '\\'))
				break if (@current == EOF)
			end
			buffer += @current
			return Token.new(STRING, buffer)
		end

		def get_operator
			buffer = ""
			loop do
				buffer.append(@current)
				consume
				break unless (is_operator)
				break if (@current == EOF)
			end
			return Token.new(OPERA, buffer)
		end

		def get_not
			buffer = ""
			loop do
				buffer += @current
				consume
				break unless (@current == '=')
				break if (@current == EOF) 
			end
			if buffer.length > 1
				return Token.new(NOTEQUAL, buffer)
			else
				return Token.new(NOT, buffer)
			end
		end

		def ws
			while 	(@current != EOF and 
					(@current == ' ' or 
					 @current == '\t' or
					 @current == '\n' or
					 @current == '\r'))
				consume
			end
		end
	end

	class LineLexer < LL1Lexer

	end

end