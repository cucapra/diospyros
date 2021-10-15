; ModuleID = 'llvm-tests/width9_new.c'
source_filename = "llvm-tests/width9_new.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.14.0"

@__const.main.a_in = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00, float 9.000000e+00], align 16
@__const.main.b_in = private unnamed_addr constant [9 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00, float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00, float 9.000000e+00], align 16
@__func__.main = private unnamed_addr constant [5 x i8] c"main\00", align 1
@.str = private unnamed_addr constant [24 x i8] c"llvm-tests/width9_new.c\00", align 1
@.str.1 = private unnamed_addr constant [14 x i8] c"c_out[0] == 2\00", align 1
@.str.2 = private unnamed_addr constant [14 x i8] c"c_out[1] == 4\00", align 1
@.str.3 = private unnamed_addr constant [14 x i8] c"c_out[2] == 6\00", align 1
@.str.4 = private unnamed_addr constant [14 x i8] c"c_out[3] == 8\00", align 1
@.str.5 = private unnamed_addr constant [15 x i8] c"c_out[4] == 10\00", align 1
@.str.6 = private unnamed_addr constant [15 x i8] c"c_out[5] == 12\00", align 1
@.str.7 = private unnamed_addr constant [15 x i8] c"c_out[6] == 14\00", align 1
@.str.8 = private unnamed_addr constant [15 x i8] c"c_out[7] == 16\00", align 1
@.str.9 = private unnamed_addr constant [15 x i8] c"c_out[8] == 18\00", align 1
@.str.10 = private unnamed_addr constant [11 x i8] c"first: %f\0A\00", align 1
@.str.11 = private unnamed_addr constant [12 x i8] c"second: %f\0A\00", align 1
@.str.12 = private unnamed_addr constant [11 x i8] c"third: %f\0A\00", align 1
@.str.13 = private unnamed_addr constant [12 x i8] c"fourth: %f\0A\00", align 1
@.str.14 = private unnamed_addr constant [11 x i8] c"fifth: %f\0A\00", align 1
@.str.15 = private unnamed_addr constant [11 x i8] c"sixth: %f\0A\00", align 1
@.str.16 = private unnamed_addr constant [13 x i8] c"seventh: %f\0A\00", align 1
@.str.17 = private unnamed_addr constant [11 x i8] c"eight: %f\0A\00", align 1
@.str.18 = private unnamed_addr constant [11 x i8] c"ninth: %f\0A\00", align 1

; Function Attrs: noinline nounwind ssp uwtable
define void @sum(float* %0, float* %1, float* %2) #0 {
  %4 = alloca float*, align 8
  %5 = alloca float*, align 8
  %6 = alloca float*, align 8
  store float* %0, float** %4, align 8
  store float* %1, float** %5, align 8
  store float* %2, float** %6, align 8
  %7 = load float*, float** %4, align 8
  %8 = getelementptr inbounds float, float* %7, i64 0
  %9 = load float, float* %8, align 4
  %10 = load float*, float** %5, align 8
  %11 = getelementptr inbounds float, float* %10, i64 0
  %12 = load float, float* %11, align 4
  %13 = fadd float %9, %12
  %14 = load float*, float** %6, align 8
  %15 = getelementptr inbounds float, float* %14, i64 0
  store float %13, float* %15, align 4
  %16 = load float*, float** %4, align 8
  %17 = getelementptr inbounds float, float* %16, i64 1
  %18 = load float, float* %17, align 4
  %19 = load float*, float** %5, align 8
  %20 = getelementptr inbounds float, float* %19, i64 1
  %21 = load float, float* %20, align 4
  %22 = fadd float %18, %21
  %23 = load float*, float** %6, align 8
  %24 = getelementptr inbounds float, float* %23, i64 1
  store float %22, float* %24, align 4
  %25 = load float*, float** %4, align 8
  %26 = getelementptr inbounds float, float* %25, i64 2
  %27 = load float, float* %26, align 4
  %28 = load float*, float** %5, align 8
  %29 = getelementptr inbounds float, float* %28, i64 2
  %30 = load float, float* %29, align 4
  %31 = fadd float %27, %30
  %32 = load float*, float** %6, align 8
  %33 = getelementptr inbounds float, float* %32, i64 2
  store float %31, float* %33, align 4
  %34 = load float*, float** %4, align 8
  %35 = getelementptr inbounds float, float* %34, i64 3
  %36 = load float, float* %35, align 4
  %37 = load float*, float** %5, align 8
  %38 = getelementptr inbounds float, float* %37, i64 3
  %39 = load float, float* %38, align 4
  %40 = fadd float %36, %39
  %41 = load float*, float** %6, align 8
  %42 = getelementptr inbounds float, float* %41, i64 3
  store float %40, float* %42, align 4
  %43 = load float*, float** %4, align 8
  %44 = getelementptr inbounds float, float* %43, i64 4
  %45 = load float, float* %44, align 4
  %46 = load float*, float** %5, align 8
  %47 = getelementptr inbounds float, float* %46, i64 4
  %48 = load float, float* %47, align 4
  %49 = fadd float %45, %48
  %50 = load float*, float** %6, align 8
  %51 = getelementptr inbounds float, float* %50, i64 4
  store float %49, float* %51, align 4
  %52 = load float*, float** %4, align 8
  %53 = getelementptr inbounds float, float* %52, i64 5
  %54 = load float, float* %53, align 4
  %55 = load float*, float** %5, align 8
  %56 = getelementptr inbounds float, float* %55, i64 5
  %57 = load float, float* %56, align 4
  %58 = fadd float %54, %57
  %59 = load float*, float** %6, align 8
  %60 = getelementptr inbounds float, float* %59, i64 5
  store float %58, float* %60, align 4
  %61 = load float*, float** %4, align 8
  %62 = getelementptr inbounds float, float* %61, i64 6
  %63 = load float, float* %62, align 4
  %64 = load float*, float** %5, align 8
  %65 = getelementptr inbounds float, float* %64, i64 6
  %66 = load float, float* %65, align 4
  %67 = fadd float %63, %66
  %68 = load float*, float** %6, align 8
  %69 = getelementptr inbounds float, float* %68, i64 6
  store float %67, float* %69, align 4
  %70 = load float*, float** %4, align 8
  %71 = getelementptr inbounds float, float* %70, i64 7
  %72 = load float, float* %71, align 4
  %73 = load float*, float** %5, align 8
  %74 = getelementptr inbounds float, float* %73, i64 7
  %75 = load float, float* %74, align 4
  %76 = fadd float %72, %75
  %77 = load float*, float** %6, align 8
  %78 = getelementptr inbounds float, float* %77, i64 7
  store float %76, float* %78, align 4
  %79 = load float*, float** %4, align 8
  %80 = getelementptr inbounds float, float* %79, i64 8
  %81 = load float, float* %80, align 4
  %82 = load float*, float** %5, align 8
  %83 = getelementptr inbounds float, float* %82, i64 8
  %84 = load float, float* %83, align 4
  %85 = fadd float %81, %84
  %86 = load float*, float** %6, align 8
  %87 = getelementptr inbounds float, float* %86, i64 8
  store float %85, float* %87, align 4
  ret void
}

; Function Attrs: noinline nounwind ssp uwtable
define i32 @main(i32 %0, i8** %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca i8**, align 8
  %6 = alloca [9 x float], align 16
  %7 = alloca [9 x float], align 16
  %8 = alloca [9 x float], align 16
  store i32 0, i32* %3, align 4
  store i32 %0, i32* %4, align 4
  store i8** %1, i8*** %5, align 8
  %9 = bitcast [9 x float]* %6 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %9, i8* align 16 bitcast ([9 x float]* @__const.main.a_in to i8*), i64 36, i1 false)
  %10 = bitcast [9 x float]* %7 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 16 %10, i8* align 16 bitcast ([9 x float]* @__const.main.b_in to i8*), i64 36, i1 false)
  %11 = getelementptr inbounds [9 x float], [9 x float]* %6, i64 0, i64 0
  %12 = getelementptr inbounds [9 x float], [9 x float]* %7, i64 0, i64 0
  %13 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 0
  call void @sum(float* %11, float* %12, float* %13)
  %14 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 0
  %15 = load float, float* %14, align 16
  %16 = fcmp oeq float %15, 2.000000e+00
  %17 = xor i1 %16, true
  %18 = zext i1 %17 to i32
  %19 = sext i32 %18 to i64
  %20 = icmp ne i64 %19, 0
  br i1 %20, label %21, label %23

21:                                               ; preds = %2
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 22, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.1, i64 0, i64 0)) #4
  unreachable

22:                                               ; No predecessors!
  br label %24

23:                                               ; preds = %2
  br label %24

24:                                               ; preds = %23, %22
  %25 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 1
  %26 = load float, float* %25, align 4
  %27 = fcmp oeq float %26, 4.000000e+00
  %28 = xor i1 %27, true
  %29 = zext i1 %28 to i32
  %30 = sext i32 %29 to i64
  %31 = icmp ne i64 %30, 0
  br i1 %31, label %32, label %34

32:                                               ; preds = %24
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 23, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.2, i64 0, i64 0)) #4
  unreachable

33:                                               ; No predecessors!
  br label %35

34:                                               ; preds = %24
  br label %35

35:                                               ; preds = %34, %33
  %36 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 2
  %37 = load float, float* %36, align 8
  %38 = fcmp oeq float %37, 6.000000e+00
  %39 = xor i1 %38, true
  %40 = zext i1 %39 to i32
  %41 = sext i32 %40 to i64
  %42 = icmp ne i64 %41, 0
  br i1 %42, label %43, label %45

43:                                               ; preds = %35
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 24, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.3, i64 0, i64 0)) #4
  unreachable

44:                                               ; No predecessors!
  br label %46

45:                                               ; preds = %35
  br label %46

46:                                               ; preds = %45, %44
  %47 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 3
  %48 = load float, float* %47, align 4
  %49 = fcmp oeq float %48, 8.000000e+00
  %50 = xor i1 %49, true
  %51 = zext i1 %50 to i32
  %52 = sext i32 %51 to i64
  %53 = icmp ne i64 %52, 0
  br i1 %53, label %54, label %56

54:                                               ; preds = %46
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 25, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @.str.4, i64 0, i64 0)) #4
  unreachable

55:                                               ; No predecessors!
  br label %57

56:                                               ; preds = %46
  br label %57

57:                                               ; preds = %56, %55
  %58 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 4
  %59 = load float, float* %58, align 16
  %60 = fcmp oeq float %59, 1.000000e+01
  %61 = xor i1 %60, true
  %62 = zext i1 %61 to i32
  %63 = sext i32 %62 to i64
  %64 = icmp ne i64 %63, 0
  br i1 %64, label %65, label %67

65:                                               ; preds = %57
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 26, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.5, i64 0, i64 0)) #4
  unreachable

66:                                               ; No predecessors!
  br label %68

67:                                               ; preds = %57
  br label %68

68:                                               ; preds = %67, %66
  %69 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 5
  %70 = load float, float* %69, align 4
  %71 = fcmp oeq float %70, 1.200000e+01
  %72 = xor i1 %71, true
  %73 = zext i1 %72 to i32
  %74 = sext i32 %73 to i64
  %75 = icmp ne i64 %74, 0
  br i1 %75, label %76, label %78

76:                                               ; preds = %68
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 27, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.6, i64 0, i64 0)) #4
  unreachable

77:                                               ; No predecessors!
  br label %79

78:                                               ; preds = %68
  br label %79

79:                                               ; preds = %78, %77
  %80 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 6
  %81 = load float, float* %80, align 8
  %82 = fcmp oeq float %81, 1.400000e+01
  %83 = xor i1 %82, true
  %84 = zext i1 %83 to i32
  %85 = sext i32 %84 to i64
  %86 = icmp ne i64 %85, 0
  br i1 %86, label %87, label %89

87:                                               ; preds = %79
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 28, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.7, i64 0, i64 0)) #4
  unreachable

88:                                               ; No predecessors!
  br label %90

89:                                               ; preds = %79
  br label %90

90:                                               ; preds = %89, %88
  %91 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 7
  %92 = load float, float* %91, align 4
  %93 = fcmp oeq float %92, 1.600000e+01
  %94 = xor i1 %93, true
  %95 = zext i1 %94 to i32
  %96 = sext i32 %95 to i64
  %97 = icmp ne i64 %96, 0
  br i1 %97, label %98, label %100

98:                                               ; preds = %90
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 29, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.8, i64 0, i64 0)) #4
  unreachable

99:                                               ; No predecessors!
  br label %101

100:                                              ; preds = %90
  br label %101

101:                                              ; preds = %100, %99
  %102 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 8
  %103 = load float, float* %102, align 16
  %104 = fcmp oeq float %103, 1.800000e+01
  %105 = xor i1 %104, true
  %106 = zext i1 %105 to i32
  %107 = sext i32 %106 to i64
  %108 = icmp ne i64 %107, 0
  br i1 %108, label %109, label %111

109:                                              ; preds = %101
  call void @__assert_rtn(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @__func__.main, i64 0, i64 0), i8* getelementptr inbounds ([24 x i8], [24 x i8]* @.str, i64 0, i64 0), i32 30, i8* getelementptr inbounds ([15 x i8], [15 x i8]* @.str.9, i64 0, i64 0)) #4
  unreachable

110:                                              ; No predecessors!
  br label %112

111:                                              ; preds = %101
  br label %112

112:                                              ; preds = %111, %110
  %113 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 0
  %114 = load float, float* %113, align 16
  %115 = fpext float %114 to double
  %116 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.10, i64 0, i64 0), double %115)
  %117 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 1
  %118 = load float, float* %117, align 4
  %119 = fpext float %118 to double
  %120 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.11, i64 0, i64 0), double %119)
  %121 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 2
  %122 = load float, float* %121, align 8
  %123 = fpext float %122 to double
  %124 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.12, i64 0, i64 0), double %123)
  %125 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 3
  %126 = load float, float* %125, align 4
  %127 = fpext float %126 to double
  %128 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @.str.13, i64 0, i64 0), double %127)
  %129 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 4
  %130 = load float, float* %129, align 16
  %131 = fpext float %130 to double
  %132 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.14, i64 0, i64 0), double %131)
  %133 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 5
  %134 = load float, float* %133, align 4
  %135 = fpext float %134 to double
  %136 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.15, i64 0, i64 0), double %135)
  %137 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 6
  %138 = load float, float* %137, align 8
  %139 = fpext float %138 to double
  %140 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @.str.16, i64 0, i64 0), double %139)
  %141 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 7
  %142 = load float, float* %141, align 4
  %143 = fpext float %142 to double
  %144 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.17, i64 0, i64 0), double %143)
  %145 = getelementptr inbounds [9 x float], [9 x float]* %8, i64 0, i64 8
  %146 = load float, float* %145, align 16
  %147 = fpext float %146 to double
  %148 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str.18, i64 0, i64 0), double %147)
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
