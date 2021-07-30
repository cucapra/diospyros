; ModuleID = 'llvm-tests/mac.c'
source_filename = "llvm-tests/mac.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@a_in = global [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@b_in = global [4 x float] [float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00], align 16
@c_in = global [4 x float] [float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00], align 16
@.str = private unnamed_addr constant [11 x i8] c"first: %i\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"second: %i\0A\00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"third: %i\0A\00", align 1
@.str.3 = private unnamed_addr constant [12 x i8] c"fourth: %i\0A\00", align 1

; Function Attrs: noinline nounwind optnone ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca [4 x i32], align 16
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  %7 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @a_in, i64 0, i64 0), align 16
  %8 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @b_in, i64 0, i64 0), align 16
  %9 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @c_in, i64 0, i64 0), align 16
  %10 = fmul float %8, %9
  %11 = fadd float %7, %10
  %12 = fptosi float %11 to i32
  %13 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 0
  store i32 %12, i32* %13, align 16
  %14 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @a_in, i64 0, i64 1), align 4
  %15 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @b_in, i64 0, i64 1), align 4
  %16 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @c_in, i64 0, i64 1), align 4
  %17 = fmul float %15, %16
  %18 = fadd float %14, %17
  %19 = fptosi float %18 to i32
  %20 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 1
  store i32 %19, i32* %20, align 4
  %21 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @a_in, i64 0, i64 2), align 8
  %22 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @b_in, i64 0, i64 2), align 8
  %23 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @c_in, i64 0, i64 2), align 8
  %24 = fmul float %22, %23
  %25 = fadd float %21, %24
  %26 = fptosi float %25 to i32
  %27 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 2
  store i32 %26, i32* %27, align 8
  %28 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @a_in, i64 0, i64 3), align 4
  %29 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @b_in, i64 0, i64 3), align 4
  %30 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @c_in, i64 0, i64 3), align 4
  %31 = fmul float %29, %30
  %32 = fadd float %28, %31
  %33 = fptosi float %32 to i32
  %34 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 3
  %35 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @a_in, i64 0, i64 0), align 4
  %36 = insertelement <4 x float> zeroinitializer, float %35, i32 0
  %37 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @a_in, i64 0, i64 1), align 4
  %38 = insertelement <4 x float> %36, float %37, i32 1
  %39 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @a_in, i64 0, i64 2), align 4
  %40 = insertelement <4 x float> %38, float %39, i32 2
  %41 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @a_in, i64 0, i64 3), align 4
  %42 = insertelement <4 x float> %40, float %41, i32 3
  %43 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @b_in, i64 0, i64 0), align 4
  %44 = insertelement <4 x float> zeroinitializer, float %43, i32 0
  %45 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @b_in, i64 0, i64 1), align 4
  %46 = insertelement <4 x float> %44, float %45, i32 1
  %47 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @b_in, i64 0, i64 2), align 4
  %48 = insertelement <4 x float> %46, float %47, i32 2
  %49 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @b_in, i64 0, i64 3), align 4
  %50 = insertelement <4 x float> %48, float %49, i32 3
  %51 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @c_in, i64 0, i64 0), align 4
  %52 = insertelement <4 x float> zeroinitializer, float %51, i32 0
  %53 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @c_in, i64 0, i64 1), align 4
  %54 = insertelement <4 x float> %52, float %53, i32 1
  %55 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @c_in, i64 0, i64 2), align 4
  %56 = insertelement <4 x float> %54, float %55, i32 2
  %57 = load float, float* getelementptr inbounds ([4 x float], [4 x float]* @c_in, i64 0, i64 3), align 4
  %58 = insertelement <4 x float> %56, float %57, i32 3
  %59 = call <4 x float> @llvm.fma.f32(<4 x float> %42, <4 x float> %50, <4 x float> %58)
  %60 = extractelement <4 x float> %59, i32 0
  %61 = getelementptr inbounds [4 x i32], float %60, i64 0, i64 0
  %62 = extractelement <4 x float> %59, i32 1
  %63 = getelementptr inbounds [4 x i32], float %62, i64 0, i64 1
  %64 = extractelement <4 x float> %59, i32 2
  %65 = getelementptr inbounds [4 x i32], float %64, i64 0, i64 2
  %66 = extractelement <4 x float> %59, i32 3
  %67 = getelementptr inbounds [4 x i32], float %66, i64 0, i64 3
  store i32 %33, i32* %34, align 4
  %68 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 0
  %69 = load i32, i32* %68, align 16
  %70 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), i32 %69)
  %71 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 1
  %72 = load i32, i32* %71, align 4
  %73 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), i32 %72)
  %74 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 2
  %75 = load i32, i32* %74, align 8
  %76 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), i32 %75)
  %77 = getelementptr inbounds [4 x i32], [4 x i32]* %6, i64 0, i64 3
  %78 = load i32, i32* %77, align 4
  %79 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), i32 %78)
  ret i32 0
}

declare i32 @printf(i8*, ...) #1

; Function Attrs: nounwind readnone speculatable willreturn
declare <4 x float> @llvm.fma.f32(<4 x float>, <4 x float>, <4 x float>) #2

attributes #0 = { noinline nounwind optnone ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone speculatable willreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
