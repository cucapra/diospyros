; ModuleID = 'clang.ll'
source_filename = "llvm-tests/2d-conv.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.mat_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], align 16
@__const.main.f_in = private unnamed_addr constant [4 x float] [float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00], align 16
@__const.main.expected = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 3.000000e+00, float 2.000000e+00, float 4.000000e+00, float 1.000000e+01, float 6.000000e+00, float 3.000000e+00, float 7.000000e+00, float 4.000000e+00], align 16
@.str = private unnamed_addr constant [12 x i8] c"output: %f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.1 = private unnamed_addr constant [21 x i8] c"llvm-tests/2d-conv.c\00", align 1
@.str.2 = private unnamed_addr constant [26 x i8] c"mat_out[i] == expected[i]\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @convolution(float* %0, float* %1, float* %2) #0 {
.preheader7:
  %3 = load float, float* %0, align 4
  %4 = load float, float* %1, align 4
  %5 = fmul float %3, %4
  %6 = load float, float* %2, align 4
  %7 = fadd float %6, %5
  store float %7, float* %2, align 4
  %8 = getelementptr inbounds float, float* %2, i64 1
  %9 = load float, float* %0, align 4
  %10 = getelementptr inbounds float, float* %1, i64 1
  %11 = load float, float* %10, align 4
  %12 = fmul float %9, %11
  %13 = load float, float* %8, align 4
  %14 = fadd float %13, %12
  store float %14, float* %8, align 4
  %15 = getelementptr inbounds float, float* %0, i64 1
  %16 = load float, float* %15, align 4
  %17 = load float, float* %1, align 4
  %18 = fmul float %16, %17
  %19 = fadd float %14, %18
  store float %19, float* %8, align 4
  %20 = getelementptr inbounds float, float* %2, i64 2
  %21 = load float, float* %15, align 4
  %22 = load float, float* %10, align 4
  %23 = fmul float %21, %22
  %24 = load float, float* %20, align 4
  %25 = fadd float %24, %23
  store float %25, float* %20, align 4
  %26 = getelementptr inbounds float, float* %2, i64 3
  %27 = load float, float* %0, align 4
  %28 = getelementptr inbounds float, float* %1, i64 2
  %29 = load float, float* %28, align 4
  %30 = fmul float %27, %29
  %31 = load float, float* %26, align 4
  %32 = fadd float %31, %30
  store float %32, float* %26, align 4
  %33 = getelementptr inbounds float, float* %0, i64 2
  %34 = load float, float* %33, align 4
  %35 = load float, float* %1, align 4
  %36 = fmul float %34, %35
  %37 = fadd float %32, %36
  store float %37, float* %26, align 4
  %38 = getelementptr inbounds float, float* %2, i64 4
  %39 = load float, float* %0, align 4
  %40 = getelementptr inbounds float, float* %1, i64 3
  %41 = load float, float* %40, align 4
  %42 = fmul float %39, %41
  %43 = load float, float* %38, align 4
  %44 = fadd float %43, %42
  store float %44, float* %38, align 4
  %45 = load float, float* %15, align 4
  %46 = load float, float* %28, align 4
  %47 = fmul float %45, %46
  %48 = fadd float %44, %47
  store float %48, float* %38, align 4
  %49 = load float, float* %33, align 4
  %50 = load float, float* %10, align 4
  %51 = fmul float %49, %50
  %52 = fadd float %48, %51
  store float %52, float* %38, align 4
  %53 = getelementptr inbounds float, float* %0, i64 3
  %54 = load float, float* %53, align 4
  %55 = load float, float* %1, align 4
  %56 = fmul float %54, %55
  %57 = fadd float %52, %56
  store float %57, float* %38, align 4
  %58 = getelementptr inbounds float, float* %2, i64 5
  %59 = load float, float* %15, align 4
  %60 = load float, float* %40, align 4
  %61 = fmul float %59, %60
  %62 = load float, float* %58, align 4
  %63 = fadd float %62, %61
  store float %63, float* %58, align 4
  %64 = load float, float* %53, align 4
  %65 = load float, float* %10, align 4
  %66 = fmul float %64, %65
  %67 = fadd float %63, %66
  store float %67, float* %58, align 4
  %68 = getelementptr inbounds float, float* %2, i64 6
  %69 = load float, float* %33, align 4
  %70 = load float, float* %28, align 4
  %71 = fmul float %69, %70
  %72 = load float, float* %68, align 4
  %73 = fadd float %72, %71
  store float %73, float* %68, align 4
  %74 = getelementptr inbounds float, float* %2, i64 7
  %75 = load float, float* %33, align 4
  %76 = load float, float* %40, align 4
  %77 = fmul float %75, %76
  %78 = load float, float* %74, align 4
  %79 = fadd float %78, %77
  store float %79, float* %74, align 4
  %80 = load float, float* %53, align 4
  %81 = load float, float* %28, align 4
  %82 = fmul float %80, %81
  %83 = fadd float %79, %82
  store float %83, float* %74, align 4
  %84 = getelementptr inbounds float, float* %2, i64 8
  %85 = load float, float* %53, align 4
  %86 = load float, float* %40, align 4
  %87 = fmul float %85, %86
  %88 = load float, float* %84, align 4
  %89 = fadd float %88, %87
  store float %89, float* %84, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca [4 x float], align 16
  %2 = alloca [4 x float], align 16
  %3 = alloca [9 x float], align 16
  %4 = bitcast [4 x float]* %1 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %4, i8* nonnull align 16 dereferenceable(16) bitcast ([4 x float]* @__const.main.mat_in to i8*), i64 16, i1 false)
  %5 = bitcast [4 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 16 dereferenceable(16) %5, i8* nonnull align 16 dereferenceable(16) bitcast ([4 x float]* @__const.main.f_in to i8*), i64 16, i1 false)
  %6 = bitcast [9 x float]* %3 to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 dereferenceable(36) %6, i8 0, i64 36, i1 false)
  %7 = getelementptr inbounds [4 x float], [4 x float]* %1, i64 0, i64 0
  %8 = getelementptr inbounds [4 x float], [4 x float]* %2, i64 0, i64 0
  %9 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 0
  call void @convolution(float* nonnull %7, float* nonnull %8, float* nonnull %9)
  %10 = load float, float* %9, align 16
  %11 = fpext float %10 to double
  %12 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %11) #5
  %13 = load float, float* %9, align 16
  %14 = fcmp une float %13, 1.000000e+00
  br i1 %14, label %22, label %15

15:                                               ; preds = %0
  %16 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 1
  %17 = load float, float* %16, align 4
  %18 = fpext float %17 to double
  %19 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %18) #5
  %20 = load float, float* %16, align 4
  %21 = fcmp une float %20, 3.000000e+00
  br i1 %21, label %22, label %23

22:                                               ; preds = %65, %58, %51, %44, %37, %30, %23, %15, %0
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([21 x i8], [21 x i8]* @.str.1, i64 0, i64 0), i32 46, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @.str.2, i64 0, i64 0)) #6
  unreachable

23:                                               ; preds = %15
  %24 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 2
  %25 = load float, float* %24, align 8
  %26 = fpext float %25 to double
  %27 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %26) #5
  %28 = load float, float* %24, align 8
  %29 = fcmp une float %28, 2.000000e+00
  br i1 %29, label %22, label %30

30:                                               ; preds = %23
  %31 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 3
  %32 = load float, float* %31, align 4
  %33 = fpext float %32 to double
  %34 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %33) #5
  %35 = load float, float* %31, align 4
  %36 = fcmp une float %35, 4.000000e+00
  br i1 %36, label %22, label %37

37:                                               ; preds = %30
  %38 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 4
  %39 = load float, float* %38, align 16
  %40 = fpext float %39 to double
  %41 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %40) #5
  %42 = load float, float* %38, align 16
  %43 = fcmp une float %42, 1.000000e+01
  br i1 %43, label %22, label %44

44:                                               ; preds = %37
  %45 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 5
  %46 = load float, float* %45, align 4
  %47 = fpext float %46 to double
  %48 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %47) #5
  %49 = load float, float* %45, align 4
  %50 = fcmp une float %49, 6.000000e+00
  br i1 %50, label %22, label %51

51:                                               ; preds = %44
  %52 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 6
  %53 = load float, float* %52, align 8
  %54 = fpext float %53 to double
  %55 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %54) #5
  %56 = load float, float* %52, align 8
  %57 = fcmp une float %56, 3.000000e+00
  br i1 %57, label %22, label %58

58:                                               ; preds = %51
  %59 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 7
  %60 = load float, float* %59, align 4
  %61 = fpext float %60 to double
  %62 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %61) #5
  %63 = load float, float* %59, align 4
  %64 = fcmp une float %63, 7.000000e+00
  br i1 %64, label %22, label %65

65:                                               ; preds = %58
  %66 = getelementptr inbounds [9 x float], [9 x float]* %3, i64 0, i64 8
  %67 = load float, float* %66, align 16
  %68 = fpext float %67 to double
  %69 = call i32 (i8*, ...) @printf(i8* nonnull dereferenceable(1) getelementptr inbounds ([12 x i8], [12 x i8]* @.str, i64 0, i64 0), double %68) #5
  %70 = load float, float* %66, align 16
  %71 = fcmp une float %70, 4.000000e+00
  br i1 %71, label %22, label %72

72:                                               ; preds = %65
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: argmemonly nounwind willreturn writeonly
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #2

declare i32 @printf(i8*, ...) #3

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #4

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { argmemonly nounwind willreturn writeonly }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { nounwind }
attributes #6 = { noreturn nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
