; ModuleID = 'llvm-tests/2d_new.c'
source_filename = "llvm-tests/2d_new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [4 x [4 x float]] [[4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], [4 x float] [float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], [4 x float] [float 9.000000e+00, float 1.000000e+01, float 1.100000e+01, float 1.200000e+01], [4 x float] [float 1.300000e+01, float 1.400000e+01, float 1.500000e+01, float 1.600000e+01]], align 16
@__const.main.b_in = private unnamed_addr constant [4 x float] [float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str = private unnamed_addr constant [20 x i8] c"llvm-tests/2d_new.c\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"c_out[0] == 9\00", align 1
@.str.2 = private unnamed_addr constant [15 x i8] c"c_out[1] == 14\00", align 1
@.str.3 = private unnamed_addr constant [15 x i8] c"c_out[2] == 19\00", align 1
@.str.4 = private unnamed_addr constant [15 x i8] c"c_out[3] == 18\00", align 1
@.str.5 = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.6 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.7 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.8 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @sum([4 x float]* %0, float* %1, float* %2) #0 {
  %4 = alloca [4 x float]*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  store [4 x float]* %0, [4 x float]** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
  %7 = load [4 x float]*, [4 x float]** %4, align 8
  %8 = getelementptr inbounds [4 x float], [4 x float]* %7, i64 0
  %9 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 3
  %10 = load float, float* %9, align 4
  %11 = load float*, float** %5, align 8
  %12 = getelementptr inbounds float, float* %11, i64 0
  %13 = load float, float* %12, align 4
  %14 = fadd float %10, %13
  %15 = load float*, float** %6, align 8
  %16 = getelementptr inbounds float, float* %15, i64 0
  store float %14, float* %16, align 4
  %17 = load [4 x float]*, [4 x float]** %4, align 8
  %18 = getelementptr inbounds [4 x float], [4 x float]* %17, i64 1
  %19 = getelementptr inbounds [4 x float], [4 x float]* %18, i64 0, i64 3
  %20 = load float, float* %19, align 4
  %21 = load float*, float** %5, align 8
  %22 = getelementptr inbounds float, float* %21, i64 1
  %23 = load float, float* %22, align 4
  %24 = fadd float %20, %23
  %25 = load float*, float** %6, align 8
  %26 = getelementptr inbounds float, float* %25, i64 1
  store float %24, float* %26, align 4
  %27 = load [4 x float]*, [4 x float]** %4, align 8
  %28 = getelementptr inbounds [4 x float], [4 x float]* %27, i64 2
  %29 = getelementptr inbounds [4 x float], [4 x float]* %28, i64 0, i64 3
  %30 = load float, float* %29, align 4
  %31 = load float*, float** %5, align 8
  %32 = getelementptr inbounds float, float* %31, i64 2
  %33 = load float, float* %32, align 4
  %34 = fadd float %30, %33
  %35 = load float*, float** %6, align 8
  %36 = getelementptr inbounds float, float* %35, i64 2
  store float %34, float* %36, align 4
  %37 = load [4 x float]*, [4 x float]** %4, align 8
  %38 = getelementptr inbounds [4 x float], [4 x float]* %37, i64 3
  %39 = getelementptr inbounds [4 x float], [4 x float]* %38, i64 0, i64 3
  %40 = load float, float* %39, align 4
  %41 = load [4 x float]*, [4 x float]** %4, align 8
  %42 = getelementptr inbounds [4 x float], [4 x float]* %41, i64 0
  %43 = getelementptr inbounds [4 x float], [4 x float]* %42, i64 0, i64 1
  %44 = load float, float* %43, align 4
  %45 = fadd float %40, %44
  %46 = load float*, float** %6, align 8
  %47 = getelementptr inbounds float, float* %46, i64 3
  store float %45, float* %47, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca [4 x [4 x float]], align 16
  %7 = alloca [4 x float], align 16
  %8 = alloca [4 x float], align 16
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  %9 = bitcast [4 x [4 x float]]* %6 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %9, i8* align 16 bitcast ([4 x [4 x float]]* @__const.main.a_in to i8*), i64 64, i1 false)
  %10 = bitcast [4 x float]* %7 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %10, i8* align 16 bitcast ([4 x float]* @__const.main.b_in to i8*), i64 16, i1 false)
  %11 = getelementptr inbounds [4 x [4 x float]], [4 x [4 x float]]* %6, i64 0, i64 0
  %12 = getelementptr inbounds [4 x float], [4 x float]* %7, i64 0, i64 0
  %13 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 0
  call void @sum([4 x float]* %11, float* %12, float* %13)
  %14 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 0
  %15 = load float, float* %14, align 16
  %16 = fcmp oeq float %15, 9.000000e+00
  %17 = xor i1 %16, true
  %18 = zext i1 %17 to i32
  %19 = sext i32 %18 to i64
  %20 = icmp ne i64 %19, 0
  br i1 %20, label %21, label %23

21:                                               ; preds = %2
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0), i32 18, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0)) #4
  unreachable

22:                                               ; No predecessors!
  br label %24

23:                                               ; preds = %2
  br label %24

24:                                               ; preds = %23, %22
  %25 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 1
  %26 = load float, float* %25, align 4
  %27 = fcmp oeq float %26, 1.400000e+01
  %28 = xor i1 %27, true
  %29 = zext i1 %28 to i32
  %30 = sext i32 %29 to i64
  %31 = icmp ne i64 %30, 0
  br i1 %31, label %32, label %34

32:                                               ; preds = %24
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0), i32 19, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.2, i64 0, i64 0)) #4
  unreachable

33:                                               ; No predecessors!
  br label %35

34:                                               ; preds = %24
  br label %35

35:                                               ; preds = %34, %33
  %36 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 2
  %37 = load float, float* %36, align 8
  %38 = fcmp oeq float %37, 1.900000e+01
  %39 = xor i1 %38, true
  %40 = zext i1 %39 to i32
  %41 = sext i32 %40 to i64
  %42 = icmp ne i64 %41, 0
  br i1 %42, label %43, label %45

43:                                               ; preds = %35
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0), i32 20, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.3, i64 0, i64 0)) #4
  unreachable

44:                                               ; No predecessors!
  br label %46

45:                                               ; preds = %35
  br label %46

46:                                               ; preds = %45, %44
  %47 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 3
  %48 = load float, float* %47, align 4
  %49 = fcmp oeq float %48, 1.800000e+01
  %50 = xor i1 %49, true
  %51 = zext i1 %50 to i32
  %52 = sext i32 %51 to i64
  %53 = icmp ne i64 %52, 0
  br i1 %53, label %54, label %56

54:                                               ; preds = %46
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([20 x i8], [20 x i8]* @.str, i64 0, i64 0), i32 21, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.4, i64 0, i64 0)) #4
  unreachable

55:                                               ; No predecessors!
  br label %57

56:                                               ; preds = %46
  br label %57

57:                                               ; preds = %56, %55
  %58 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 0
  %59 = load float, float* %58, align 16
  %60 = fpext float %59 to double
  %61 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.5, i64 0, i64 0), double %60)
  %62 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 1
  %63 = load float, float* %62, align 4
  %64 = fpext float %63 to double
  %65 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.6, i64 0, i64 0), double %64)
  %66 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 2
  %67 = load float, float* %66, align 8
  %68 = fpext float %67 to double
  %69 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.7, i64 0, i64 0), double %68)
  %70 = getelementptr inbounds [4 x float], [4 x float]* %8, i64 0, i64 3
  %71 = load float, float* %70, align 4
  %72 = fpext float %71 to double
  %73 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.8, i64 0, i64 0), double %72)
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #2

declare i32 @printf(i8*, ...) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
