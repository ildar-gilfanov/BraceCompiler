//  LLVMIRGen.swift
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

import cllvm

class LLVMIRGen {
    private let ast: ASTNode
    
    init(ast: ASTNode) {
        self.ast = ast
    }
    
    func printTo(_ fileName: String, dump: Bool) {
        let module = generateModule()
        defer {
            LLVMDisposeModule(module)
        }
        
        let builder = generateBuilder()
        defer {
            LLVMDisposeBuilder(builder)
        }
        
        let putsFunction = generateExternalPutsFunction(module: module)
        
        generateMainFunction(builder: builder, module: module) {
            handleAST(ast, putsFunction: putsFunction, builder: builder)
        }
        
        if dump {
            LLVMDumpModule(module)
        }
        
        LLVMPrintModuleToFile(module, fileName, nil)
    }
    
    private func generateModule() -> LLVMModuleRef {
        let moduleName = "BraceCompiller"
        return LLVMModuleCreateWithName(moduleName)
    }
    
    private func generateBuilder() -> LLVMBuilderRef {
        return LLVMCreateBuilder()
    }
    
    private func generateExternalPutsFunction(module: LLVMModuleRef) -> LLVMValueRef {
        var putParamTypes = UnsafeMutablePointer<LLVMTypeRef?>.allocate(capacity: 1)
        defer {
            putParamTypes.deallocate()
        }
        putParamTypes[0] = LLVMPointerType(LLVMInt8Type(), 0)
        
        let putFunctionType = LLVMFunctionType(LLVMInt32Type(), putParamTypes, 1, 0)
        
        return LLVMAddFunction(module, "puts", putFunctionType)
    }
    
    private func generateMainFunction(builder: LLVMBuilderRef,
                                      module: LLVMModuleRef,
                                      mainInternalGenerator: () -> Void) {
        
        let mainFunctionType = LLVMFunctionType(LLVMInt32Type(), nil, 0, 0)
        let mainFunction = LLVMAddFunction(module, "main", mainFunctionType)
        
        let mainEntryBlock = LLVMAppendBasicBlock(mainFunction, "entry")
        LLVMPositionBuilderAtEnd(builder, mainEntryBlock)
        
        mainInternalGenerator()
        
        let zero = LLVMConstInt(LLVMInt32Type(), 0, 0)
        LLVMBuildRet(builder, zero)
    }
    
    private func handleAST(_ ast: ASTNode, putsFunction: LLVMValueRef, builder: LLVMBuilderRef) {
        switch ast {
        case let .brace(childNode):
            guard let childNode = childNode else {
                break
            }
            
            handleAST(childNode, putsFunction: putsFunction, builder: builder)
        case let .number(value):
            generatePrint(value: value, putsFunction: putsFunction, builder: builder)
        }
    }
    
    private func generatePrint(value: Int, putsFunction: LLVMValueRef, builder: LLVMBuilderRef) {
        let putArgumentsSize = MemoryLayout<LLVMValueRef?>.size
        let putArguments = UnsafeMutablePointer<LLVMValueRef?>.allocate(capacity: 1)
        defer {
            putArguments.deallocate()
        }
        putArguments[0] = LLVMBuildGlobalStringPtr(builder, "\(value)", "print")
        
        _ = LLVMBuildCall(builder, putsFunction, putArguments, 1, "put")
    }
}
