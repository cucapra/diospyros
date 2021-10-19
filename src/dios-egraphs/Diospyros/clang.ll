; ModuleID = 'llvm-tests/scalar-new.c'
source_filename = "llvm-tests/scalar-new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [8 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [8 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00], align 16
@.str = private unnamed_addr constant [4 x i8] c"%f\0A\00", align 1
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str.1 = private unnamed_addr constant [24 x i8] c"llvm-tests/scalar-new.c\00", align 1
@.str.2 = private unnamed_addr constant [14 x i8] c"b_in[0] == 10\00", align 1
@.str.3 = private unnamed_addr constant [14 x i8] c"b_in[1] == 20\00", align 1
@.str.4 = private unnamed_addr constant [14 x i8] c"b_in[2] == 30\00", align 1
@.str.5 = private unnamed_addr constant [14 x i8] c"b_in[3] == 40\00", align 1
@.str.6 = private unnamed_addr constant [14 x i8] c"b_in[4] == 50\00", align 1
@.str.7 = private unnamed_addr constant [14 x i8] c"b_in[5] == 60\00", align 1
@.str.8 = private unnamed_addr constant [14 x i8] c"b_in[6] == 70\00", align 1
@.str.9 = private unnamed_addr constant [14 x i8] c"b_in[7] == 80\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @matrix_multiply(float* %0, float %1, float* %2) #0 {
  %4 = alloca float*, align 8
  %5 = alloca float, align 4
  %6 = alloca float*, align 8
  %7 = alloca i32, align 4
  store float* %0, float** %4, align 8
  store float %1, float* %5, align 4
  store float* %2, float** %6, align 8
  store i32 0, i32* %7, align 4
  br label %8

8:                                                ; preds = %23, %3
  %9 = load i32, i32* %7, align 4
  %10 = icmp slt i32 %9, 8
  br i1 %10, label %11, label %26

11:                                               ; preds = %8
  %12 = load float*, float** %4, align 8
  %13 = load i32, i32* %7, align 4
  %14 = sext i32 %13 to i64
  %15 = getelementptr inbounds float, float* %12, i64 %14
  %16 = load float, float* %15, align 4
  %17 = load float, float* %5, align 4
  %18 = fmul float %16, %17
  %19 = load float*, float** %6, align 8
  %20 = load i32, i32* %7, align 4
  %21 = sext i32 %20 to i64
  %22 = getelementptr inbounds float, float* %19, i64 %21
  store float %18, float* %22, align 4
  br label %23

23:                                               ; preds = %11
  %24 = load i32, i32* %7, align 4
  %25 = add nsw i32 %24, 1
  store i32 %25, i32* %7, align 4
  br label %8

26:                                               ; preds = %8
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca [8 x float], align 16
  %3 = alloca float, align 4
  %4 = alloca [8 x float], align 16
  %5 = alloca i32, align 4
  store i32 0, i32* %1, align 4
  %6 = bitcast [8 x float]* %2 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %6, i8* align 16 bitcast ([8 x float]* @__const.main.a_in to i8*), i64 32, i1 false)
  store float 1.000000e+01, float* %3, align 4
  %7 = bitcast [8 x float]* %4 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %7, i8* align 16 bitcast ([8 x float]* @__const.main.b_in to i8*), i64 32, i1 false)
  %8 = getelementptr inbounds [8 x float], [8 x float]* %2, i64 0, i64 0
  %9 = load float, float* %3, align 4
  %10 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 0
  call void @matrix_multiply(float* %8, float %9, float* %10)
  store i32 0, i32* %5, align 4
  br label %11

11:                                               ; preds = %21, %0
  %12 = load i32, i32* %5, align 4
  %13 = icmp slt i32 %12, 8
  br i1 %13, label %14, label %24

14:                                               ; preds = %11
  %15 = load i32, i32* %5, align 4
  %16 = sext i32 %15 to i64
  %17 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 %16
  %18 = load float, float* %17, align 4
  %19 = fpext float %18 to double
  %20 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str, i64 0, i64 0), double %19)
  br label %21

21:                                               ; preds = %14
  %22 = load i32, i32* %5, align 4
  %23 = add nsw i32 %22, 1
  store i32 %23, i32* %5, align 4
  br label %11

24:                                               ; preds = %11
  %25 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 0
  %26 = load float, float* %25, align 16
  %27 = fcmp oeq float %26, 1.000000e+01
  %28 = xor i1 %27, true
  %29 = zext i1 %28 to i32
  %30 = sext i32 %29 to i64
  %31 = icmp ne i64 %30, 0
  br i1 %31, label %32, label %34

32:                                               ; preds = %24
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 19, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.2, i64 0, i64 0)) #4
  unreachable

33:                                               ; No predecessors!
  br label %35

34:                                               ; preds = %24
  br label %35

35:                                               ; preds = %34, %33
  %36 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 1
  %37 = load float, float* %36, align 4
  %38 = fcmp oeq float %37, 2.000000e+01
  %39 = xor i1 %38, true
  %40 = zext i1 %39 to i32
  %41 = sext i32 %40 to i64
  %42 = icmp ne i64 %41, 0
  br i1 %42, label %43, label %45

43:                                               ; preds = %35
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 20, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0)) #4
  unreachable

44:                                               ; No predecessors!
  br label %46

45:                                               ; preds = %35
  br label %46

46:                                               ; preds = %45, %44
  %47 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 2
  %48 = load float, float* %47, align 8
  %49 = fcmp oeq float %48, 3.000000e+01
  %50 = xor i1 %49, true
  %51 = zext i1 %50 to i32
  %52 = sext i32 %51 to i64
  %53 = icmp ne i64 %52, 0
  br i1 %53, label %54, label %56

54:                                               ; preds = %46
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 21, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.4, i64 0, i64 0)) #4
  unreachable

55:                                               ; No predecessors!
  br label %57

56:                                               ; preds = %46
  br label %57

57:                                               ; preds = %56, %55
  %58 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 3
  %59 = load float, float* %58, align 4
  %60 = fcmp oeq float %59, 4.000000e+01
  %61 = xor i1 %60, true
  %62 = zext i1 %61 to i32
  %63 = sext i32 %62 to i64
  %64 = icmp ne i64 %63, 0
  br i1 %64, label %65, label %67

65:                                               ; preds = %57
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 22, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.5, i64 0, i64 0)) #4
  unreachable

66:                                               ; No predecessors!
  br label %68

67:                                               ; preds = %57
  br label %68

68:                                               ; preds = %67, %66
  %69 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 4
  %70 = load float, float* %69, align 16
  %71 = fcmp oeq float %70, 5.000000e+01
  %72 = xor i1 %71, true
  %73 = zext i1 %72 to i32
  %74 = sext i32 %73 to i64
  %75 = icmp ne i64 %74, 0
  br i1 %75, label %76, label %78

76:                                               ; preds = %68
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 23, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.6, i64 0, i64 0)) #4
  unreachable

77:                                               ; No predecessors!
  br label %79

78:                                               ; preds = %68
  br label %79

79:                                               ; preds = %78, %77
  %80 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 5
  %81 = load float, float* %80, align 4
  %82 = fcmp oeq float %81, 6.000000e+01
  %83 = xor i1 %82, true
  %84 = zext i1 %83 to i32
  %85 = sext i32 %84 to i64
  %86 = icmp ne i64 %85, 0
  br i1 %86, label %87, label %89

87:                                               ; preds = %79
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 24, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.7, i64 0, i64 0)) #4
  unreachable

88:                                               ; No predecessors!
  br label %90

89:                                               ; preds = %79
  br label %90

90:                                               ; preds = %89, %88
  %91 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 6
  %92 = load float, float* %91, align 8
  %93 = fcmp oeq float %92, 7.000000e+01
  %94 = xor i1 %93, true
  %95 = zext i1 %94 to i32
  %96 = sext i32 %95 to i64
  %97 = icmp ne i64 %96, 0
  br i1 %97, label %98, label %100

98:                                               ; preds = %90
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 25, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.8, i64 0, i64 0)) #4
  unreachable

99:                                               ; No predecessors!
  br label %101

100:                                              ; preds = %90
  br label %101

101:                                              ; preds = %100, %99
  %102 = getelementptr inbounds [8 x float], [8 x float]* %4, i64 0, i64 7
  %103 = load float, float* %102, align 4
  %104 = fcmp oeq float %103, 8.000000e+01
  %105 = xor i1 %104, true
  %106 = zext i1 %105 to i32
  %107 = sext i32 %106 to i64
  %108 = icmp ne i64 %107, 0
  br i1 %108, label %109, label %111

109:                                              ; preds = %101
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str.1, i64 0, i64 0), i32 26, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.9, i64 0, i64 0)) #4
  unreachable

110:                                              ; No predecessors!
  br label %112

111:                                              ; preds = %101
  br label %112

112:                                              ; preds = %111, %110
  %113 = load i32, i32* %1, align 4
  ret i32 %113
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #1

declare i32 @printf(i8*, ...) #2

; Function Attrs: noreturn
declare void @__assert_rtn(i8*, i8*, i32, i8*) #3

attributes #0 = { noinline nounwind ssp uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="true" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="penryn" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sahf,+sse,+sse2,+sse3,+sse4.1,+ssse3,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { noreturn }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{!"clang version 11.0.1"}
