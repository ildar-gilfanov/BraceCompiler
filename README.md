# BraceCompiler

## Build project

1. Install LLVM `brew install llvm`
2. Download or clone project `git clone git@github.com:ildar-gilfanov/BraceCompiler.git`
3. Change folder `cd BraceCompiler`
4. Run building `swift build -Xcc -I$(llvm-config --includedir) -Xlinker -L$(llvm-config --libdir) $(llvm-config --libs | sed s/-l/"-Xlinker -l"/g) $(llvm-config --system-libs | sed s/-l/"-Xlinker -l"/g) -Xlinker -lc++ -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.14"`

## Run compilation

Pass input and output file to BraceCompiler:

`.build/debug/BraceCompiler Example/input.b Example/output.ll`

## Create Xcode project (optional)

1. Generate project `swift package generate-xcodeproj`
2. Open `open BraceCompiler.xcodeproj`
3. Add output of `llvm-config --libdir` to Library Search Path
4. Add output of `llvm-config --includedir` to Header Search Path
5. Add libLLVM.dylib, located in `llvm-config --libdir`, to Linked Frameworks and Libraries
6. Run building `cmd+b`
7. Find binary file in Products folder and run compilation `BraceCompiler input.b output.ll`

## Execute LLVM IR

Pass your .ll file to lli command:

`lli output.ll`