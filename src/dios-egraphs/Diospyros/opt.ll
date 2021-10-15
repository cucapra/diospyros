; ModuleID = 'clang.ll'
source_filename = "llvm-tests/five_binops_new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [4 x float] [float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@__const.main.c_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.d_in = private unnamed_addr constant [4 x float] [float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@__const.main.e_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.3 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @add5(float* %0, float* %1, float* %2, float* %3, float* %4, float* %5) #0 {
  %7 = getelementptr inbounds float, float* %0, i64 0
  %8 = load float, float* %7, align 4
  %9 = getelementptr inbounds float, float* %1, i64 0
  %10 = load float, float* %9, align 4
  %11 = fadd float %8, %10
  %12 = getelementptr inbounds float, float* %2, i64 0
  %13 = load float, float* %12, align 4
  %14 = fadd float %11, %13
  %15 = getelementptr inbounds float, float* %3, i64 0
  %16 = load float, float* %15, align 4
  %17 = fadd float %14, %16
  %18 = getelementptr inbounds float, float* %4, i64 0
  %19 = load float, float* %18, align 4
  %20 = fadd float %17, %19
  %21 = getelementptr inbounds float, float* %5, i64 0
  store float %20, float* %21, align 4
  %22 = getelementptr inbounds float, float* %0, i64 1
  %23 = load float, float* %22, align 4
  %24 = getelementptr inbounds float, float* %1, i64 1
  %25 = load float, float* %24, align 4
  %26 = fadd float %23, %25
  %27 = getelementptr inbounds float, float* %2, i64 1
  %28 = load float, float* %27, align 4
  %29 = fadd float %26, %28
  %30 = getelementptr inbounds float, float* %3, i64 1
  %31 = load float, float* %30, align 4
  %32 = fadd float %29, %31
  %33 = getelementptr inbounds float, float* %4, i64 1
  %34 = load float, float* %33, align 4
  %35 = fadd float %32, %34
  %36 = getelementptr inbounds float, float* %5, i64 1
  store float %35, float* %36, align 4
  %37 = getelementptr inbounds float, float* %0, i64 2
  %38 = load float, float* %37, align 4
  %39 = getelementptr inbounds float, float* %1, i64 2
  %40 = load float, float* %39, align 4
  %41 = fadd float %38, %40
  %42 = getelementptr inbounds float, float* %2, i64 2
  %43 = load float, float* %42, align 4
  %44 = fadd float %41, %43
  %45 = getelementptr inbounds float, float* %3, i64 2
  %46 = load float, float* %45, align 4
  %47 = fadd float %44, %46
  %48 = getelementptr inbounds float, float* %4, i64 2
  %49 = load float, float* %48, align 4
  %50 = fadd float %47, %49
  %51 = getelementptr inbounds float, float* %5, i64 2
  store float %50, float* %51, align 4
  %52 = getelementptr inbounds float, float* %0, i64 3
  %53 = load float, float* %52, align 4
  %54 = getelementptr inbounds float, float* %1, i64 3
  %55 = load float, float* %54, align 4
  %56 = fadd float %53, %55
  %57 = getelementptr inbounds float, float* %2, i64 3
  %58 = load float, float* %57, align 4
  %59 = fadd float %56, %58
  %60 = getelementptr inbounds float, float* %3, i64 3
  %61 = load float, float* %60, align 4
  %62 = fadd float %59, %61
  %63 = getelementptr inbounds float, float* %4, i64 3
  %64 = load float, float* %63, align 4
  %65 = fadd float %62, %64
  %66 = getelementptr inbounds float, float* %5, i64 3
  store float %65, float* %66, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca [4 x float], align 16
  %4 = alloca [4 x float], align 16
  %5 = alloca [4 x float], align 16
  %6 = alloca [4 x float], align 16
  %7 = alloca [4 x float], align 16
  %8 = alloca [4 x float], align 16
  %9 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %9, i8* align 16 bitcast ([4 x float]* @__const.main.a_in to i8*), i64 16, i1 false)
  %10 = bitcast [4 x float]* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %10, i8* align 16 bitcast ([4 x float]* @__const.main.b_in to i8*), i64 16, i1 false)
  %11 = bitcast [4 x float]* %5 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %11, i8* align 16 bitcast ([4 x float]* @__const.main.c_in to i8*), i64 16, i1 false)
  %12 = bitcast [4 x float]* %6 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %12, i8* align 16 bitcast ([4 x float]* @__const.main.d_in to i8*), i64 16, i1 false)
  %13 = bitcast [4 x float]* %7 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %13, i8* align 16 bitcast ([4 x float]* @__const.main.e_in to i8*), i64 16, i1 false)
  %14 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %15 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 0
  %16 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  %17 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 0
  %18 = getelementptr inbounds [4 x float], [4 x float]* %7, i64 0, i64 0
  %19 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 0
  call void @add5(float* %14, float* %15, float* %16, float* %17, float* %18, float* %19)
  %20 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 0
  %21 = load float, float* %20, align 16
  %22 = fpext float %21 to double
  %23 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), double %22)
  %24 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 1
  %25 = load float, float* %24, align 4
  %26 = fpext float %25 to double
  %27 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), double %26)
  %28 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 2
  %29 = load float, float* %28, align 8
  %30 = fpext float %29 to double
  %31 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), double %30)
  %32 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 3
  %33 = load float, float* %32, align 4
  %34 = fpext float %33 to double
  %35 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), double %34)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

declare i32 @printf(i8*, ...) #2

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
