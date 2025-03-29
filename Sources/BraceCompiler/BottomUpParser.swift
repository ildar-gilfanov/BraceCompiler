//  BottomUpParser.swift
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

class BottomUpParser {
    private enum State {
        case state1
        case state2
    }
    
    private let tokens: [Token]
    private var index: Int
    private var state: State = .state1
    private var stack: [Token] = []
    private var rootNode: ASTNode?
    private var currentToken: Token? {
        return index != tokens.endIndex ? tokens[index] : nil
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
        index = tokens.startIndex
    }
    
    func startParsing() -> ASTNode? {
        do {
            guard !tokens.isEmpty else {
                throw ParserError.expectedOpenBrace
            }
            
            while index != tokens.endIndex {
                try parseNextToken()
                moveIndex()
            }
            
            guard stack.isEmpty else {
                rootNode = nil
                throw ParserError.expectedCloseBrace
            }
        } catch ParserError.expectedCloseBrace {
            rootNode = nil
            print("Expected close brace at index \(index)")
        } catch ParserError.expectedOpenBrace {
            rootNode = nil
            print("Expected open brace at index \(index)")
        } catch ParserError.expectedEndOfArray {
            rootNode = nil
            print("Expected end of tokens array at index \(index)")
        } catch {
            rootNode = nil
            print("Unexpected error")
        }
        
        return rootNode
    }
    
    private func parseNextToken() throws {
        guard let currentToken = currentToken else {
            return
        }
        
        switch (state, currentToken) {
        case (.state1, .openBraceToken):
            print("Open brace found")
            stack.append(.openBraceToken)
        case (.state1, .number(let value)):
            if stack.isEmpty {
                throw ParserError.expectedOpenBrace
            } else {
                consumeNumber(value: value)
                state = .state2
            }
        case (.state1, .closeBraceToken):
            if stack.isEmpty {
                throw ParserError.expectedOpenBrace
            } else {
                consumeCloseBrace()
                state = .state2
            }
        case (.state2, .closeBraceToken):
            if stack.isEmpty {
                throw ParserError.expectedEndOfArray
            } else {
                consumeCloseBrace()
            }
        case (.state2, .number), (.state2, .openBraceToken):
            if stack.isEmpty {
                throw ParserError.expectedEndOfArray
            } else {
                throw ParserError.expectedCloseBrace
            }
        }
    }
    
    private func consumeCloseBrace() {
        print("Close brace found")
        _ = stack.popLast()
        print("Pair found")
        
        if rootNode == nil {
            rootNode = .brace(childNode: nil)
        } else {
            rootNode = .brace(childNode: rootNode)
        }
    }
    
    private func consumeNumber(value: Int) {
        rootNode = .number(value: value)
    }
    
    private func moveIndex() {
        tokens.formIndex(after: &index)
    }
}
