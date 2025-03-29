//  main.swift
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

guard CommandLine.arguments.count == 3,
    let string = try? String(contentsOfFile: CommandLine.arguments[1]) else {
        
    print("Pass input and output files name")
    exit(1)
}

print("Lexer ---------------------------------------")

let lexer = Lexer(string: string)
let tokens = lexer.startAnalyzing()

print("Tokens: \(tokens)")

print("TDParser ------------------------------------")

let parserTD = TopDownParser(tokens: tokens)
let ast1 = parserTD.startParsing()

if let ast = ast1 {
    print("AST: \(ast)")
} else {
    print("AST: nil")
}

print("BUParser ------------------------------------")

let parserBU = BottomUpParser(tokens: tokens)
let ast2 = parserBU.startParsing()

if let ast = ast2 {
    print("AST: \(ast)")
} else {
    print("AST: nil")
}

print("LLVMIRGen -----------------------------------")

if let ast = ast1 {
    let llvmIRGen = LLVMIRGen(ast: ast)
    llvmIRGen.printTo(CommandLine.arguments[2], dump: false)
}

print("Finish")
