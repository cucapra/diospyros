; ModuleID = 'build/opt.ll'
source_filename = "fail-tests/local-array-4.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@.str = private unnamed_addr constant [14 x i8] c"A Output: %f\0A\00", align 1
@.memset_pattern = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16

; Function Attrs: noinline nounwind ssp uwtable
define void @test(float* %0) #0 {
.preheader:
  %1 = alloca i64, align 8
  %tmpcast = bitcast i64* %1 to [2 x float]*
  %2 = bitcast i64* %1 to i8*
  %3 = bitcast i64* %1 to float*
  store i64 0, i64* %1, align 8
  call void @memset_pattern16(i8* nonnull %2, i8* bitcast ([4 x float]* @.memset_pattern to i8*), i64 8) #4
  %4 = load float, float* %3, align 8
  %5 = fadd float %4, 0.000000e+00
  %6 = getelementptr inbounds [2 x float], [2 x float]* %tmpcast, i64 0, i64 1
  %7 = load float, float* %6, align 4
  %8 = fadd float %5, %7
  store float %8, float* %0, align 4
  ret void
}

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #1

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca i64, align 8
  %tmpcast = bitcast i64* %1 to [2 x float]*
  %2 = bitcast i64* %1 to float*
  store float 0.000000e+00, float* %2, align 8
  %3 = getelementptr inbounds [2 x float], [2 x float]* %tmpcast, i64 0, i64 1
  store float 1.000000e+00, float* %3, align 4
  call void @test(float* nonnull %2)
  %4 = load float, float* %2, align 8
  %5 = fpext float %4 to double
  %6 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), double %5) #4
  %7 = load float, float* %3, align 4
  %8 = fpext float %7 to double
  %9 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([14 x i8], [14 x i8]* @.str, i64 0, i64 0), double %8) #4
  ret i32 0
}

declare i32 @printf(i8*, ...) #2

; Function Attrs: argmemonly nofree
declare void @memset_pattern16(i8* nocapture, i8* nocapture readonly, i64) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn writeonly }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { argmemonly nofree }
attributes #4 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
