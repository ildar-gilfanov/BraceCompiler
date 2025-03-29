//  TopDownParser.swift
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

class TopDownParser {
    private let tokens: [Token]
    private var index: Int
    private var currentToken: Token? {
        return index != tokens.endIndex ? tokens[index] : nil
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
        index = tokens.startIndex
    }
    
    func startParsing() -> ASTNode? {
        var rootNode: ASTNode?
        
        do {
            rootNode = try parseBraces()
            
            guard currentToken == nil else {
                rootNode = nil
                throw ParserError.expectedEndOfArray
            }
        } catch ParserError.expectedCloseBrace {
            print("Expected close brace at index \(index)")
        } catch ParserError.expectedOpenBrace {
            print("Expected open brace at index \(index)")
        } catch ParserError.expectedEndOfArray {
            print("Expected end of tokens array at index \(index)")
        } catch {
            print("Unexpected error")
        }
        
        return rootNode
    }
    
    private func parseBraces() throws -> ASTNode? {
        try consumeOpenBrace()
        print("Pair found")
        
        let node: ASTNode?
        if let currentToken = self.currentToken,
            case .openBraceToken = currentToken {
            
            node = .brace(childNode: try parseBraces())
        } else if let currentToken = self.currentToken,
            case let .number(value) = currentToken {
            
            node = .brace(childNode: .number(value: value))
            try consumeNumber()
        } else {
            node = .brace(childNode: nil)
        }
        
        try consumeCloseBrace()
        
        return node
    }
    
    private func consumeOpenBrace() throws {
        if let currentToken = self.currentToken,
            case .openBraceToken = currentToken {
            
            print("Open brace found")
            moveIndex()
        } else {
            throw ParserError.expectedOpenBrace
        }
    }
    
    private func consumeCloseBrace() throws {
        if let currentToken = self.currentToken,
            case .closeBraceToken = currentToken {
            
            print("Close brace found")
            moveIndex()
        } else {
            throw ParserError.expectedCloseBrace
        }
    }
    
    private func consumeNumber() throws {
        if let currentToken = self.currentToken,
            case .number = currentToken {
            
            moveIndex()
        } else {
            throw ParserError.expectedNumber
        }
    }
    
    private func moveIndex() {
        tokens.formIndex(after: &index)
    }
}
