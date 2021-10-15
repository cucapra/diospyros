; ModuleID = 'opt.ll'
source_filename = "llvm-tests/add.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [4 x float] [float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@.str = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.1 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.2 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.3 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @sum(float* %0, float* %1, float* %2) #0 {
  %4 = getelementptr inbounds float, float* %0, i64 0
  %5 = load float, float* %4, align 4
  %6 = insertelement <4 x float> zeroinitializer, float %5, i32 0
  %7 = getelementptr inbounds float, float* %0, i64 1
  %8 = load float, float* %7, align 4
  %9 = insertelement <4 x float> %6, float %8, i32 1
  %10 = getelementptr inbounds float, float* %0, i64 2
  %11 = load float, float* %10, align 4
  %12 = insertelement <4 x float> %9, float %11, i32 2
  %13 = getelementptr inbounds float, float* %0, i64 3
  %14 = load float, float* %13, align 4
  %15 = insertelement <4 x float> %12, float %14, i32 3
  %16 = getelementptr inbounds float, float* %1, i64 0
  %17 = load float, float* %16, align 4
  %18 = insertelement <4 x float> zeroinitializer, float %17, i32 0
  %19 = getelementptr inbounds float, float* %1, i64 1
  %20 = load float, float* %19, align 4
  %21 = insertelement <4 x float> %18, float %20, i32 1
  %22 = getelementptr inbounds float, float* %1, i64 2
  %23 = load float, float* %22, align 4
  %24 = insertelement <4 x float> %21, float %23, i32 2
  %25 = getelementptr inbounds float, float* %1, i64 3
  %26 = load float, float* %25, align 4
  %27 = insertelement <4 x float> %24, float %26, i32 3
  %28 = fadd <4 x float> %15, %27
  %29 = extractelement <4 x float> %28, i32 0
  %30 = getelementptr inbounds float, float* %2, i64 0
  store float %29, float* %30, align 4
  %31 = extractelement <4 x float> %28, i32 1
  %32 = getelementptr inbounds float, float* %2, i64 1
  store float %31, float* %32, align 4
  %33 = extractelement <4 x float> %28, i32 2
  %34 = getelementptr inbounds float, float* %2, i64 2
  store float %33, float* %34, align 4
  %35 = extractelement <4 x float> %28, i32 3
  %36 = getelementptr inbounds float, float* %2, i64 3
  store float %35, float* %36, align 4
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca [4 x float], align 16
  %4 = alloca [4 x float], align 16
  %5 = alloca [4 x float], align 16
  %6 = bitcast [4 x float]* %3 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([4 x float]* @__const.main.a_in to i8*), i64 16, i1 false)
  %7 = bitcast [4 x float]* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([4 x float]* @__const.main.b_in to i8*), i64 16, i1 false)
  %8 = getelementptr inbounds [4 x float], [4 x float]* %3, i64 0, i64 0
  %9 = getelementptr inbounds [4 x float], [4 x float]* %4, i64 0, i64 0
  %10 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  call void @sum(float* %8, float* %9, float* %10)
  %11 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 0
  %12 = load float, float* %11, align 16
  %13 = fpext float %12 to double
  %14 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), double %13)
  %15 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 1
  %16 = load float, float* %15, align 4
  %17 = fpext float %16 to double
  %18 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), double %17)
  %19 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 2
  %20 = load float, float* %19, align 8
  %21 = fpext float %20 to double
  %22 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), double %21)
  %23 = getelementptr inbounds [4 x float], [4 x float]* %5, i64 0, i64 3
  %24 = load float, float* %23, align 4
  %25 = fpext float %24 to double
  %26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), double %25)
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
