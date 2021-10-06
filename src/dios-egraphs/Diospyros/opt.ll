; ModuleID = 'clang.ll'
source_filename = "llvm-tests/matrix_multiply.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.3 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @matrix_multiply(float* %0, float* %1, float* %2) #0 {
  store float 0.000000e+00, float* %2, align 4
  %4 = load float, float* %0, align 4
  %5 = load float, float* %1, align 4
  %6 = fmul float %4, %5
  %7 = load float, float* %2, align 4
  %8 = fadd float %7, %6
  store float %8, float* %2, align 4
  %9 = getelementptr inbounds float, float* %0, i64 1
  %10 = load float, float* %9, align 4
  %11 = getelementptr inbounds float, float* %1, i64 2
  %12 = load float, float* %11, align 4
  %13 = fmul float %10, %12
  %14 = load float, float* %2, align 4
  %15 = fadd float %14, %13
  store float %15, float* %2, align 4
  %16 = getelementptr inbounds float, float* %2, i64 1
  store float 0.000000e+00, float* %16, align 4
  %17 = getelementptr inbounds float, float* %2, i64 1
  %18 = load float, float* %0, align 4
  %19 = getelementptr inbounds float, float* %1, i64 1
  %20 = load float, float* %19, align 4
  %21 = fmul float %18, %20
  %22 = load float, float* %17, align 4
  %23 = fadd float %22, %21
  store float %23, float* %17, align 4
  %24 = getelementptr inbounds float, float* %0, i64 1
  %25 = load float, float* %24, align 4
  %26 = getelementptr inbounds float, float* %1, i64 3
  %27 = load float, float* %26, align 4
  %28 = fmul float %25, %27
  %29 = load float, float* %17, align 4
  %30 = fadd float %29, %28
  store float %30, float* %17, align 4
  %31 = getelementptr inbounds float, float* %2, i64 2
  store float 0.000000e+00, float* %31, align 4
  %32 = getelementptr inbounds float, float* %2, i64 2
  %33 = getelementptr inbounds float, float* %0, i64 2
  %34 = load float, float* %33, align 4
  %35 = load float, float* %1, align 4
  %36 = fmul float %34, %35
  %37 = load float, float* %32, align 4
  %38 = fadd float %37, %36
  store float %38, float* %32, align 4
  %39 = getelementptr inbounds float, float* %0, i64 3
  %40 = load float, float* %39, align 4
  %41 = getelementptr inbounds float, float* %1, i64 2
  %42 = load float, float* %41, align 4
  %43 = fmul float %40, %42
  %44 = load float, float* %32, align 4
  %45 = fadd float %44, %43
  store float %45, float* %32, align 4
  %46 = getelementptr inbounds float, float* %2, i64 3
  store float 0.000000e+00, float* %46, align 4
  %47 = getelementptr inbounds float, float* %2, i64 3
  %48 = getelementptr inbounds float, float* %0, i64 2
  %49 = load float, float* %48, align 4
  %50 = getelementptr inbounds float, float* %1, i64 1
  %51 = load float, float* %50, align 4
  %52 = fmul float %49, %51
  %53 = load float, float* %47, align 4
  %54 = fadd float %53, %52
  store float %54, float* %47, align 4
  %55 = getelementptr inbounds float, float* %0, i64 3
  %56 = load float, float* %55, align 4
  %57 = getelementptr inbounds float, float* %1, i64 3
  %58 = load float, float* %57, align 4
  %59 = fmul float %56, %58
  %60 = load float, float* %47, align 4
  %61 = fadd float %60, %59
  store float %61, float* %47, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [4 x float], align 16
  %2 = alloca [4 x float], align 16
  %3 = alloca [4 x float], align 16
  %4 = bitcast [4 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %4, i8* align 16 bitcast ([4 x float]* @__const.main.a_in to i8*), i64 16, i1 false)
  %5 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %5, i8* align 16 bitcast ([4 x float]* @__const.main.b_in to i8*), i64 16, i1 false)
  %6 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* align 16 %6, i8 0, i64 16, i1 false)
  %7 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  call void @matrix_multiply(float* %7, float* %8, float* %9)
  %10 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %11 = load float, float* %10, align 16
  %12 = fpext float %11 to double
  %13 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), double %12)
  %14 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 1
  %15 = load float, float* %14, align 4
  %16 = fpext float %15 to double
  %17 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), double %16)
  %18 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 2
  %19 = load float, float* %18, align 8
  %20 = fpext float %19 to double
  %21 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), double %20)
  %22 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 3
  %23 = load float, float* %22, align 4
  %24 = fpext float %23 to double
  %25 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), double %24)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
