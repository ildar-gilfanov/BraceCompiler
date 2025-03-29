//  Lexer.swift
//
//  Copyright (c) 2019 Ildar Gilfanov
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

class Lexer {
    private let string: String
    private var index: String.Index
    private var currentCharacter: Character? {
        return index != string.endIndex ? string[index] : nil
    }
    
    init(string: String) {
        self.string = string
        index = string.startIndex
    }
    
    func startAnalyzing() -> [Token] {
        var result: [Token] = []
        
        do {
            while let token = try getNextToken() {
                result.append(token)
            }
        } catch LexerError.unexpectedCharacted {
            print("Unexpected character at index \(index.encodedOffset)")
            result = []
        } catch LexerError.invalidNumber {
            print("Invalid number at index \(index.encodedOffset)")
            result = []
        } catch {
            print("Unexpected error")
            result = []
        }
        
        return result
    }
    
    private func getNextToken() throws -> Token? {
        guard let character = currentCharacter else {
            return nil
        }
        
        switch character {
        case "{":
            return getOpenBrace()
        case "}":
            return getCloseBrace()
        default:
            break
        }
        
        if let scalar = character.unicodeScalars.first,
            CharacterSet.decimalDigits.contains(scalar) {
            
            return try getNumber()
        }
        
        throw LexerError.unexpectedCharacted
    }
    
    private func getOpenBrace() -> Token {
        moveIndex()
        return Token.openBraceToken
    }
    
    private func getCloseBrace() -> Token {
        moveIndex()
        return Token.closeBraceToken
    }
    
    private func getNumber() throws -> Token {
        var numberString = ""
        
        while let character = currentCharacter,
            let scalar = character.unicodeScalars.first,
            CharacterSet.decimalDigits.contains(scalar) {
                
                numberString.append(character)
                moveIndex()
        }
        
        guard let number = Int(numberString) else {
            throw LexerError.invalidNumber
        }
        
        return Token.number(number)
    }
    
    private func moveIndex() {
        string.formIndex(after: &index)
    }
}
