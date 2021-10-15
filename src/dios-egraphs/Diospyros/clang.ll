; ModuleID = 'llvm-tests/five_binops_new.c'
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
  %7 = alloca float*, align 8
  %8 = alloca float*, align 8
  %9 = alloca float*, align 8
  %10 = alloca float*, align 8
  %11 = alloca float*, align 8
  %12 = alloca float*, align 8
  store float* %0, float** %7, align 8
  store float* %1, float** %8, align 8
  store float* %2, float** %9, align 8
  store float* %3, float** %10, align 8
  store float* %4, float** %11, align 8
  store float* %5, float** %12, align 8
  %13 = load float*, float** %7, align 8
  %14 = getelementptr inbounds float, float* %13, i64 0
  %15 = load float, float* %14, align 4
  %16 = load float*, float** %8, align 8
  %17 = getelementptr inbounds float, float* %16, i64 0
  %18 = load float, float* %17, align 4
  %19 = fadd float %15, %18
  %20 = load float*, float** %9, align 8
  %21 = getelementptr inbounds float, float* %20, i64 0
  %22 = load float, float* %21, align 4
  %23 = fadd float %19, %22
  %24 = load float*, float** %10, align 8
  %25 = getelementptr inbounds float, float* %24, i64 0
  %26 = load float, float* %25, align 4
  %27 = fadd float %23, %26
  %28 = load float*, float** %11, align 8
  %29 = getelementptr inbounds float, float* %28, i64 0
  %30 = load float, float* %29, align 4
  %31 = fadd float %27, %30
  %32 = load float*, float** %12, align 8
  %33 = getelementptr inbounds float, float* %32, i64 0
  store float %31, float* %33, align 4
  %34 = load float*, float** %7, align 8
  %35 = getelementptr inbounds float, float* %34, i64 1
  %36 = load float, float* %35, align 4
  %37 = load float*, float** %8, align 8
  %38 = getelementptr inbounds float, float* %37, i64 1
  %39 = load float, float* %38, align 4
  %40 = fadd float %36, %39
  %41 = load float*, float** %9, align 8
  %42 = getelementptr inbounds float, float* %41, i64 1
  %43 = load float, float* %42, align 4
  %44 = fadd float %40, %43
  %45 = load float*, float** %10, align 8
  %46 = getelementptr inbounds float, float* %45, i64 1
  %47 = load float, float* %46, align 4
  %48 = fadd float %44, %47
  %49 = load float*, float** %11, align 8
  %50 = getelementptr inbounds float, float* %49, i64 1
  %51 = load float, float* %50, align 4
  %52 = fadd float %48, %51
  %53 = load float*, float** %12, align 8
  %54 = getelementptr inbounds float, float* %53, i64 1
  store float %52, float* %54, align 4
  %55 = load float*, float** %7, align 8
  %56 = getelementptr inbounds float, float* %55, i64 2
  %57 = load float, float* %56, align 4
  %58 = load float*, float** %8, align 8
  %59 = getelementptr inbounds float, float* %58, i64 2
  %60 = load float, float* %59, align 4
  %61 = fadd float %57, %60
  %62 = load float*, float** %9, align 8
  %63 = getelementptr inbounds float, float* %62, i64 2
  %64 = load float, float* %63, align 4
  %65 = fadd float %61, %64
  %66 = load float*, float** %10, align 8
  %67 = getelementptr inbounds float, float* %66, i64 2
  %68 = load float, float* %67, align 4
  %69 = fadd float %65, %68
  %70 = load float*, float** %11, align 8
  %71 = getelementptr inbounds float, float* %70, i64 2
  %72 = load float, float* %71, align 4
  %73 = fadd float %69, %72
  %74 = load float*, float** %12, align 8
  %75 = getelementptr inbounds float, float* %74, i64 2
  store float %73, float* %75, align 4
  %76 = load float*, float** %7, align 8
  %77 = getelementptr inbounds float, float* %76, i64 3
  %78 = load float, float* %77, align 4
  %79 = load float*, float** %8, align 8
  %80 = getelementptr inbounds float, float* %79, i64 3
  %81 = load float, float* %80, align 4
  %82 = fadd float %78, %81
  %83 = load float*, float** %9, align 8
  %84 = getelementptr inbounds float, float* %83, i64 3
  %85 = load float, float* %84, align 4
  %86 = fadd float %82, %85
  %87 = load float*, float** %10, align 8
  %88 = getelementptr inbounds float, float* %87, i64 3
  %89 = load float, float* %88, align 4
  %90 = fadd float %86, %89
  %91 = load float*, float** %11, align 8
  %92 = getelementptr inbounds float, float* %91, i64 3
  %93 = load float, float* %92, align 4
  %94 = fadd float %90, %93
  %95 = load float*, float** %12, align 8
  %96 = getelementptr inbounds float, float* %95, i64 3
  store float %94, float* %96, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca [4 x float], align 16
  %7 = alloca [4 x float], align 16
  %8 = alloca [4 x float], align 16
  %9 = alloca [4 x float], align 16
  %10 = alloca [4 x float], align 16
  %11 = alloca [4 x float], align 16
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  %12 = bitcast [4 x float]* %6 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %12, i8* align 16 bitcast ([4 x float]* @__const.main.a_in to i8*), i64 16, i1 false)
  %13 = bitcast [4 x float]* %7 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %13, i8* align 16 bitcast ([4 x float]* @__const.main.b_in to i8*), i64 16, i1 false)
  %14 = bitcast [4 x float]* %8 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %14, i8* align 16 bitcast ([4 x float]* @__const.main.c_in to i8*), i64 16, i1 false)
  %15 = bitcast [4 x float]* %9 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %15, i8* align 16 bitcast ([4 x float]* @__const.main.d_in to i8*), i64 16, i1 false)
  %16 = bitcast [4 x float]* %10 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %16, i8* align 16 bitcast ([4 x float]* @__const.main.e_in to i8*), i64 16, i1 false)
  %17 = getelementptr inbounds [4 x float], [4 x float]* %6, i64 0, i64 0
  %18 = getelementptr inbounds [4 x float], [4 x float]* %7, i64 0, i64 0
  %19 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 0
  %20 = getelementptr inbounds [4 x float], [4 x float]* %9, i64 0, i64 0
  %21 = getelementptr inbounds [4 x float], [4 x float]* %10, i64 0, i64 0
  %22 = getelementptr inbounds [4 x float], [4 x float]* %11, i64 0, i64 0
  call void @add5(float* %17, float* %18, float* %19, float* %20, float* %21, float* %22)
  %23 = getelementptr inbounds [4 x float], [4 x float]* %11, i64 0, i64 0
  %24 = load float, float* %23, align 16
  %25 = fpext float %24 to double
  %26 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str, i64 0, i64 0), double %25)
  %27 = getelementptr inbounds [4 x float], [4 x float]* %11, i64 0, i64 1
  %28 = load float, float* %27, align 4
  %29 = fpext float %28 to double
  %30 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.1, i64 0, i64 0), double %29)
  %31 = getelementptr inbounds [4 x float], [4 x float]* %11, i64 0, i64 2
  %32 = load float, float* %31, align 8
  %33 = fpext float %32 to double
  %34 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.2, i64 0, i64 0), double %33)
  %35 = getelementptr inbounds [4 x float], [4 x float]* %11, i64 0, i64 3
  %36 = load float, float* %35, align 4
  %37 = fpext float %36 to double
  %38 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.3, i64 0, i64 0), double %37)
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
