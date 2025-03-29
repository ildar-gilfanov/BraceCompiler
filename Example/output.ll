; ModuleID = 'BraceCompiller'
source_filename = "BraceCompiller"

@print = private unnamed_addr constant [5 x i8] c"5678\00"

declare i32 @puts(i8*)

define i32 @main() {
entry:
  %put = call i32 @puts(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @print, i32 0, i32 0))
  ret i32 0
}
